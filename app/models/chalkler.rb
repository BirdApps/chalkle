require 'avatar_uploader'

class Chalkler < ActiveRecord::Base
  mount_uploader :avatar, AvatarUploader

  EMAIL_VALIDATION_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :registerable, :invitable, :omniauth_providers => [:facebook]

  attr_accessible *BASIC_ATTR = [:bio, :email, :name, :password, :password_confirmation, :remember_me, :email_frequency, :phone_number, :provider_teachers, :provider_admins, :providers_adminable, :visible, :address, :longitude, :latitude, :location, :avatar ]
  attr_accessible *BASIC_ATTR, :provider_ids, :provider, :uid, :join_providers, :role, :as => :admin

  attr_accessor :join_providers, :set_password_token

  validates_presence_of :name
  validates :email, allow_blank: true, format: { with: EMAIL_VALIDATION_REGEX }
  validates_uniqueness_of :email, { case_sensitive: false }
  validates_presence_of :email, :if => :email_required?
  validates_associated :subscriptions, :providers_following
  validates_presence_of :notification_preference, :if => :persisted?

  validate :passwords_match, on: :create

  has_many :subscriptions
  has_many :provider_teachers
  has_many :bookings
  has_many :booker_only_bookings, class_name: 'Booking', foreign_key: :booker_id
  has_many :provider_admins
  has_many :notifications
  has_many :sent_notifications, class_name: 'Notification', foreign_key: :from_chalkler_id
  has_many :payments, through: :bookings
  has_many :providers_teachable, through: :provider_teachers, source: :provider
  has_many :providers_adminable, through: :provider_admins, source: :provider
  has_many :courses_adminable, through: :providers_adminable, source: :courses
  has_many :courses_teaching, through: :provider_teachers, source: :courses
  has_many :courses, through: :bookings, uniq: :true
  has_many :providers_attended, through: :bookings, source: :provider, uniq: true
  has_many :providers_following, through: :subscriptions, source: :provider
  has_many :provider_contacts
  has_many :identities, class_name: 'OmniauthIdentity', dependent: :destroy, inverse_of: :user, foreign_key: :user_id  do
    def for_provider(provider)
      where(provider: provider).first
    end
  end
  has_many :course_notices
  has_many :courses_teaching, through: :provider_teachers, source: :courses
  has_one  :notification_preference
  belongs_to  :current_provider, class_name: 'Provider', foreign_key: :current_provider_id

  after_create :create_provider_associations
  after_create -> (chalkler) { NotificationPreference.create chalkler: chalkler }
  after_create -> (chalkler) { Notify.for(chalkler).welcome unless chalkler.invited_to_sign_up? }
  after_invitation_accepted -> (chalkler) { 
    chalkler.join_psuedo_identities!
    Notify.for(chalkler).welcome } 

  scope :visible, where(visible: true)
  scope :created_week_of, lambda{|date| where('created_at BETWEEN ? AND ?', date.beginning_of_week, date.end_of_week ) }
  scope :created_month_of, lambda{|date| where('created_at BETWEEN ? AND ?', date.beginning_of_month, date.end_of_month ) }

  scope :signed_in_since, lambda{|date| where('last_sign_in_at > ?', date) }
  scope :super, -> { where(role: 'super') }

  scope :learned, includes(:bookings).where("bookings.id IS NOT NULL")
  scope :taught, includes(:provider_teachers).where("provider_teachers.id IS NOT NULL" )
  scope :provided, includes(:provider_admins).where("provider_admins.id IS NOT NULL" )


  EMAIL_FREQUENCY_OPTIONS = %w(never daily weekly)

  before_create :set_reset_password_token
  before_validation :ensure_notification_preference

  def super?
    role == 'super'
  end

  def teacher? 
    provider_teachers.any? 
  end

  def provider_admin? 
    provider_admins.any?
  end

  def join_psuedo_identities!
    #TODO: make them method run on verify email, rather than on sign up
    ProviderTeacher.where(pseudo_chalkler_email: email).update_all(chalkler_id: id)
    ProviderAdmin.where(pseudo_chalkler_email: email).update_all(chalkler_id: id)
    Booking.where(pseudo_chalkler_email: email, invite_chalkler: true).update_all(chalkler_id: id)
  end

  def attending?(course)
    bookings.confirmed.where(course_id: course.id).present?
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

  def initials
    initials = name[0]
    parts = name.split ' '
    if parts.count > 1
      initials.concat parts.last[0]
    end
    initials.upcase
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
      chalkler.notification_preference = NotificationPreference.create
      chalkler.password = Devise.friendly_token[0,20]
      chalkler.identities << identity
      chalkler
    end
  end

  def is_following?(provider)
    providers_following.exists?(provider)
  end

  def email_required?
    identities.empty?
  end

  def password_required?
    false
  end

  def available_notifications
    _available_notifications = { chalkler: NotificationPreference::CHALKLER_OPTIONS }
    if teacher?
      _available_notifications[:teacher] = NotificationPreference::TEACHER_OPTIONS
    end
    if provider_admin?
      _available_notifications[:provider_admin] = NotificationPreference::PROVIDER_OPTIONS
    end
    if super?
      _available_notifications[:super_admin] = NotificationPreference::SUPER_OPTIONS
    end

    _available_notifications
  end


  
  def send_notification(type, href, message, target = nil, from = nil, image = nil, valid_from = DateTime.current.advance(minutes: -1), valid_till = nil)
    
    ## GET AN IMAGE
    # if from a chalkler
    image = from.avatar if image.blank? && from.present? && from.respond_to?('avatar')
    # if from a booking
    image = target.image if image.blank? && target.present? && target.respond_to?('image')
    # if from a collection (of bookings)
    image = target.first.image if image.blank? && target.present? && target.is_a?(Enumerable) && target.first.respond_to?('image')
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

    #save only if not a duplicate of unread notification
    Notification.create(notification, as: :admin) unless notifications.where(viewed_at: nil, href: notification[:href], message: notification[:message]).present?
    
  end

  def first_name
    name ? name.split(' ')[0] : ''
  end

  def last_name
    (name && name.split.count > 1) ? name.split(' ',2)[1] : ''
  end

  def email_about?(preference_attr)
    unless notification_preference
      self.notification_preference = NotificationPreference.create
    end
    self.notification_preference.send preference_attr
  end

  def timezone
     ActiveSupport::TimeZone.new("Pacific/Auckland")
  end

  def recommended_providers
    common_followers = providers_following.map{ |p| p.followers }.flatten.uniq
    common_providers = common_followers.map{ |p| p.providers_following }.flatten.uniq
    common_providers - self.providers_following
  end


  def recommended_courses
    recommended_providers.map{|p| p.courses.displayable.in_future }.flatten.sort{ |a,b| a.created_at <=> b.created_at }
  end

  def following_courses_in_next_week
    providers_following.map{|p| p.courses.displayable.start_at_between(DateTime.current, DateTime.current.advance(weeks: 1)) }.flatten.sort{ |a,b| a.created_at <=> b.created_at }
  end

  private

    def passwords_match
      unless identities.present? && identities[0].provider == 'facebook'
        errors.add('Passwords', 'They must match') unless password == password_confirmation
      end
    end

    def ensure_notification_preference
      self.notification_preference = NotificationPreference.create unless notification_preference.present?
    end

    def set_reset_password_token
      return unless self.set_password_token
      self.password = Chalkler.reset_password_token
      self.reset_password_token = Chalkler.reset_password_token
      self.reset_password_sent_at = Time.current
    end

    def create_provider_associations  
      return unless join_providers.is_a?(Array)
      join_providers.reject(&:empty?).each do |provider_id|
        if Subscription.where(chalkler_id: id, provider_id: provider_id).count == 0
          Subscription.create(chalkler: self, provider: provider.find(provider_id) )
        end
      end
      save!
    end
    
end