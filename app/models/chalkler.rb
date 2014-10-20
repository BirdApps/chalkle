require 'avatar_uploader'

class Chalkler < ActiveRecord::Base
  mount_uploader :avatar, AvatarUploader

  # geocoded_by :address
  # reverse_geocoded_by :latitude, :longitude
  # after_validation :reverse_geocode
  # after_validation :geocode


  EMAIL_VALIDATION_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  devise :database_authenticatable, :recoverable, :rememberable, :trackable,
    :validatable, :omniauthable, :registerable, :omniauth_providers => [:facebook, :meetup]

  attr_accessible *BASIC_ATTR = [:bio, :email, :name, :password, :password_confirmation, :remember_me, :email_frequency, :email_categories, :phone_number, :email_regions, :channel_teachers, :channel_admins, :channels_adminable, :visible, :address, :longitude, :latitude, :avatar ]
  attr_accessible *BASIC_ATTR, :channel_ids, :provider, :uid, :join_channels, :email_region_ids, :as => :admin

  attr_accessor :join_channels, :set_password_token

  validates_presence_of :name
  validates :email, allow_blank: true, format: { with: EMAIL_VALIDATION_REGEX }
  validates_uniqueness_of :email, { case_sensitive: false }
  validates_presence_of :email, :if => :email_required?
  validates_associated :subscriptions, :channels

  has_many :subscriptions
  has_many :channel_teachers
  has_many :bookings
  has_many :channel_admins
  has_many :payments, through: :bookings
  has_many :channels_teachable, through: :channel_teachers, source: :channel
  has_many :channels_adminable, through: :channel_admins, source: :channel
  has_many :courses_adminable, through: :channels_adminable, source: :courses
  has_many :courses_teaching, through: :channel_teachers, source: :courses
  has_many :courses, through: :bookings
  has_many :channels, through: :subscriptions, source: :channel
  has_many :identities, class_name: 'OmniauthIdentity', dependent: :destroy, inverse_of: :user, foreign_key: :user_id  do
    def for_provider(provider)
      where(provider: provider).first
    end
  end
  has_many :courses_teaching, through: :channel_teachers, source: :courses

  after_create :create_channel_associations

  scope :visible, where(visible: true)
  scope :with_email_region_id, 
    lambda {|region| 
      where("email_region_ids LIKE '%?%'", region)
    }

  search_methods :with_email_region_id

  serialize :email_categories
  serialize :email_region_ids

  EMAIL_FREQUENCY_OPTIONS = %w(never daily weekly)

  before_create :set_reset_password_token


  def adminable_courses
    courses_adminable.merge courses_teaching    
  end

  def join_psuedo_identities!
    ChannelTeacher.where(pseudo_chalkler_email: email).update_all(chalkler_id: id)
    ChannelAdmin.where(pseudo_chalkler_email: email).update_all(chalkler_id: id)
  end

  def upcoming_teaching
    (courses_adminable.in_future+courses_teaching.in_future).uniq.sort_by(&:start_at) 
  end

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
    self.reset_password_sent_at = Time.current
  end

  def create_channel_associations  
    return unless join_channels.is_a?(Array)
    join_channels.reject(&:empty?).each do |channel_id|
      if Subscription.where(chalkler_id: id, channel_id: channel_id).count == 0
        channels << Channel.find(channel_id)
      end
    end
    save!
  end


end
