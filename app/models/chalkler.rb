require 'omni_avatar/has_avatar'

class Chalkler < ActiveRecord::Base
  include OmniAvatar::HasAvatar

  devise :database_authenticatable, :recoverable, :rememberable, :trackable,
    :validatable, :omniauthable, :registerable

  attr_accessible :bio, :email, :name, :password, :password_confirmation,
    :remember_me, :email_frequency, :email_categories, :email_streams,
    :phone_number
  attr_accessible :bio, :email, :meetup_data, :meetup_id, :name, :password,
    :password_confirmation, :remember_me, :channel_ids, :provider, :uid,
    :email_frequency, :email_categories, :email_streams, :phone_number,
    :join_channels, :as => :admin

  attr_accessor :join_channels, :set_password_token

  validates_presence_of :name
  validates_uniqueness_of :meetup_id, allow_blank: true
  validates :email, allow_blank: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }, uniqueness: { case_sensitive: false }
  validates_presence_of :email, :unless => :meetup_id?

  has_many :subscriptions
  has_many :channels, through: :subscriptions, source: :channel
  has_many :bookings
  has_many :lessons, :through => :bookings
  has_many :lessons_taught, class_name: "Lesson", foreign_key: "teacher_id"
  has_many :payments

  scope :teachers, joins(:lessons_taught).uniq

  serialize :email_categories
  serialize :email_streams

  EMAIL_FREQUENCY_OPTIONS = %w(never daily weekly)

  before_create :set_reset_password_token

  #TODO: Move into a presenter class like Draper sometime
  def self.email_frequency_select_options
    EMAIL_FREQUENCY_OPTIONS.map { |eo| [eo.titleize, eo] }
  end

  def email_required?
    false
  end

  def password_required?
    false
  end

  def meetup_data
    data = read_attribute(:meetup_data)
    if data.present?
      member = JSON.parse(data)
      member["member"]
    else
      {}
    end
  end

  def self.find_for_meetup_oauth(auth, signed_in_resource=nil)
    chalkler = Chalkler.where(:provider => auth[:provider], :uid => auth[:uid].to_s).first
    unless chalkler
      chalkler = Chalkler.new
      chalkler.name = auth[:extra][:raw_info][:name]
      chalkler.provider = auth[:provider]
      chalkler.uid = auth[:uid].to_s
      chalkler.meetup_id = auth[:uid]
      chalkler.email = auth[:info][:email]
      chalkler.password = Devise.friendly_token[0,20]
    end
    chalkler
  end

  private

  # for Chalklers created outside of meetup
  def set_reset_password_token
    return unless self.set_password_token
    self.password = Chalkler.reset_password_token
    self.reset_password_token = Chalkler.reset_password_token
    self.reset_password_sent_at = Time.now.utc
  end

end
