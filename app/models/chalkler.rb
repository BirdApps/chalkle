require 'omni_avatar/has_avatar'

class Chalkler < ActiveRecord::Base
  include OmniAvatar::HasAvatar

  EMAIL_VALIDATION_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  devise :database_authenticatable, :recoverable, :rememberable, :trackable,
    :validatable, :omniauthable, :registerable, :omniauth_providers => [:facebook, :meetup]

  attr_accessible :bio, :email, :name, :password, :password_confirmation,
    :remember_me, :email_frequency, :email_categories,
    :phone_number, :email_regions
  attr_accessible :bio, :email, :name, :password,
    :password_confirmation, :remember_me, :channel_ids, :provider, :uid,
    :email_frequency, :email_categories, :phone_number,
    :join_channels, :email_regions, :email_region_ids, :as => :admin

  attr_accessor :join_channels, :set_password_token

  validates_presence_of :name
  validates :email, allow_blank: true, format: { with: EMAIL_VALIDATION_REGEX }, uniqueness: { case_sensitive: false }
  validates_presence_of :email, :if => :email_required?
  validates_associated :subscriptions, :channels

  has_one  :course_filter, class_name: 'Filters::Filter', dependent: :destroy
  has_many :subscriptions
  has_many :channels, through: :subscriptions, source: :channel
  has_many :bookings
  has_many :courses, :through => :bookings
  has_many :courses_taught, class_name: "Course", foreign_key: "teacher_id"
  has_many :payments
  has_many :identities, class_name: 'OmniauthIdentity', dependent: :destroy, inverse_of: :user, foreign_key: :user_id  do
    def for_provider(provider)
      where(provider: provider).first
    end
  end

  after_create :create_channel_associations

  scope :teachers, joins(:courses_taught).uniq
  scope :with_email_region_id, 
    lambda {|region| 
      where("email_region_ids LIKE '%?%'", region)
    }

  search_methods :with_email_region_id

  serialize :email_categories
  serialize :email_region_ids

  EMAIL_FREQUENCY_OPTIONS = %w(never daily weekly)

  before_create :set_reset_password_token

  class << self
    #TODO: Move into a presenter class like Draper sometime
    def email_frequency_select_options
      EMAIL_FREQUENCY_OPTIONS.map { |eo| [eo.titleize, eo] }
    end

    def find_by_meetup_id(meetup_id)
      identity = OmniauthIdentity.where(uid: meetup_id.to_s, provider: 'meetup').first
      identity.user if identity
    end

    def find_for_meetup_oauth(auth, signed_in_resource=nil)
      chalkler = where(:provider => auth[:provider], :uid => auth[:uid].to_s).first
      unless chalkler
        chalkler = self.new
        chalkler.name = auth[:extra][:raw_info][:name]
        chalkler.provider = auth[:provider]
        chalkler.uid = auth[:uid].to_s
        chalkler.email = auth[:info][:email]
        chalkler.password = Devise.friendly_token[0,20]
      end
      chalkler
    end

    def find_or_create_for_identity(identity)
      return identity.user if identity.user

      chalkler = for_identity_email(identity) || build_for_identity(identity)
      chalkler.save!
      identity.user = chalkler
      identity.save!
      chalkler
    end

    def for_identity_email(identity)
      find_by_email(identity.email) unless identity.email.blank?
    end

    def build_for_identity(identity)
      chalkler = self.new
      chalkler.name = identity.name
      chalkler.email = identity.email
      chalkler.password = Devise.friendly_token[0,20]
      chalkler.identities << identity
      chalkler
    end
  end

  def is_following?(channel)
    channels.exists?(channel)
  end

  def email_required?
    identities.empty?
  end

  def password_required?
    false
  end

  def meetup_data
    identity = meetup_identity
    identity ? identity.provider_data : {}
  end

  def meetup_id
    identity = identities.for_provider('meetup')
    identity.uid.to_i if identity
  end

  def meetup_identity
    identities.for_provider('meetup')
  end

  def email_regions
    Region.find (email_region_ids || [])
  end

  def email_regions=(email_region)
  assign_attributes({ :email_region_ids => email_region.select{|id| Region.exists?(id)}.map!(&:to_i) }, :as => :admin)
  end
  

  private

  # for Chalklers created outside of meetup
  def set_reset_password_token
    return unless self.set_password_token
    self.password = Chalkler.reset_password_token
    self.reset_password_token = Chalkler.reset_password_token
    self.reset_password_sent_at = Time.now.utc
  end

  def create_channel_associations  
    return unless join_channels.is_a?(Array)
    join_channels.reject(&:empty?).each do |channel_id|
      channels << Channel.find(channel_id) unless channels.include?(Channel.find(channel_id))
    end
    save!
  end


end
