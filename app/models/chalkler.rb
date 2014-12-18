require 'avatar_uploader'

class Chalkler < ActiveRecord::Base
  mount_uploader :avatar, AvatarUploader

  # geocoded_by :address
  # reverse_geocoded_by :latitude, :longitude
  # after_validation :reverse_geocode
  # after_validation :geocode


  EMAIL_VALIDATION_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :registerable, :omniauth_providers => [:facebook, :meetup]

  attr_accessible *BASIC_ATTR = [:bio, :email, :name, :password, :password_confirmation, :remember_me, :email_frequency, :email_categories, :phone_number, :email_regions, :channel_teachers, :channel_admins, :channels_adminable, :visible, :address, :longitude, :latitude, :avatar ]
  attr_accessible *BASIC_ATTR, :channel_ids, :provider, :uid, :join_channels, :email_region_ids, :role, :as => :admin

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
  has_many :notifications
  has_many :sent_notifications, class_name: 'Notification', foreign_key: :from_chalkler_id
  has_many :payments, through: :bookings
  has_many :channels_teachable, through: :channel_teachers, source: :channel
  has_many :channels_adminable, through: :channel_admins, source: :channel
  has_many :courses_adminable, through: :channels_adminable, source: :courses
  has_many :courses_teaching, through: :channel_teachers, source: :courses
  has_many :courses, through: :bookings
  has_many :channels, through: :subscriptions, source: :channel
  has_many :channel_contacts
  has_many :identities, class_name: 'OmniauthIdentity', dependent: :destroy, inverse_of: :user, foreign_key: :user_id  do
    def for_provider(provider)
      where(provider: provider).first
    end
  end
  has_many :course_notices
  has_many :courses_teaching, through: :channel_teachers, source: :courses
  has_one  :notification_preference

  after_create :create_channel_associations
  after_create -> (chalkler) { NotificationPreference.create chalkler: chalkler }
  after_create -> (chalkler) { Notify.for(chalkler).welcome }
  
  scope :visible, where(visible: true)
  scope :with_email_region_id, 
    lambda {|region| 
      where("email_region_ids LIKE '%?%'", region)
    }
  scope :created_week_of, lambda{|date| where('created_at BETWEEN ? AND ?', date.beginning_of_week, date.end_of_week ) }
  scope :created_month_of, lambda{|date| where('created_at BETWEEN ? AND ?', date.beginning_of_month, date.end_of_month ) }

  scope :signed_in_since, lambda{|date| where('last_sign_in_at > ?', date) }

  serialize :email_categories
  serialize :email_region_ids

  EMAIL_FREQUENCY_OPTIONS = %w(never daily weekly)

  before_create :set_reset_password_token

  def super?
    role == 'super'
  end

  def teacher? 
    channel_teachers.any? 
  end

  def channel_admin? 
    channel_admins.any?
  end

  def join_psuedo_identities!
    ChannelTeacher.where(pseudo_chalkler_email: email).update_all(chalkler_id: id)
    ChannelAdmin.where(pseudo_chalkler_email: email).update_all(chalkler_id: id)
  end

  def upcoming_teaching
    (courses_adminable.in_future+courses_teaching.in_future).uniq.sort_by{ |c| c.start_at.present? ? c.start_at : DateTime.current.advance(years: 1)}
  end

  def all_teaching
     (courses_adminable+courses_teaching).uniq.sort_by{ |c| c.start_at.present? ? c.start_at : DateTime.current.advance(years: 1)}
  end

  def confirmed_courses
    courses.merge(Booking.confirmed).uniq.in_future.by_date
  end

  def chalkler
    self
  end

  class << self

    def exists?(email)
      Chalkler.exists(email).present?
    end

    def exists(email)
      Chalkler.find(:first, conditions: ["lower(email) = ?", email.strip.downcase]) if email.present?
    end

    def stats_for_date_and_range(date, range)
      {
        new: send("created_#{range}_of", date).count, 
        active: (signed_in_since date.send("beginning_of_#{range}") ).count
      }
    end

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

  def avialable_notifications
    _available_notifications = { chalkler: NotificationPreference::CHALKLER_OPTIONS }
    if teacher?
      _available_notifications[:teacher] = NotificationPreference::TEACHER_OPTIONS
    end
    if channel_admin?
      _available_notifications[:channel_admin] = NotificationPreference::PROVIDER_OPTIONS
    end
    _available_notifications
  end


  
  def send_notification(type, href, message, target = nil,from = nil, image = nil, valid_from = DateTime.current.advance(minutes: -1), valid_till = nil)
    
    ## GET AN IMAGE
    # if from a chalkler
    image = from.avatar if image.blank? && from.present? && from.respond_to?('avatar')
    # if from a booking
    image = target.image if image.blank? && target.present? && target.respond_to?('image')
    # if from a course
    image = target.course_upload_image if image.blank? && target.present? && target.respond_to?('course_upload_image')
    
    #extract url from img
    image = image.url if image && image.respond_to?('url')
    image = Notification.default_image(type) unless image

    notification = {
      notification_type:  type,
      href:               href,
      message:            message,
      image:              image,
      target:             target,
      valid_from:         valid_from,
      valid_till:         valid_till,
      chalkler:           self
    }
    Notification.create notification, as: :admin
  end

  def first_name
    name ? name.split(' ')[0] : ''
  end

  def email_about?(preference_attr)
    if notification_preference.present?
      notification_preference.email_about?(preference_attr)
    else
      true
    end
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
