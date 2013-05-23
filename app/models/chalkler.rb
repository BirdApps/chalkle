class Chalkler < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :rememberable, :trackable,
    :validatable, :omniauthable, :registerable

  attr_accessible :bio, :email, :name, :password, :password_confirmation,
    :remember_me, :gst, :email_frequency, :email_categories, :email_streams,
    :phone_number
  attr_accessible :bio, :email, :meetup_data, :meetup_id, :name, :password,
    :password_confirmation, :remember_me, :channel_ids, :gst, :provider, :uid,
    :email_frequency, :email_categories, :email_streams, :phone_number,
    :join_channels, :as => :admin

  attr_accessor :join_channels, :set_password_token

  validates_presence_of :name
  validates_uniqueness_of :meetup_id, allow_blank: true
  validates :email, allow_blank: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }, uniqueness: { case_sensitive: false }
  validates_presence_of :join_channels, :on => :create
  validates_presence_of :channel_ids, :on => :update
  validates_presence_of :email, :unless => :meetup_id?

  has_many :channel_chalklers
  has_many :channels, :through => :channel_chalklers
  has_many :bookings
  has_many :lessons, :through => :bookings
  has_many :lessons_taught, class_name: "Lesson", foreign_key: "teacher_id"
  has_many :payments

  scope :teachers, joins(:lessons_taught).uniq

  serialize :email_categories
  serialize :email_streams

  EMAIL_FREQUENCY_OPTIONS = %w(never daily weekly)

  before_create :set_from_meetup_data, :set_reset_password_token

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

  def self.import_from_meetup(result, channel)
    chalkler = Chalkler.find_by_meetup_id(result.id)
    if chalkler.nil?
      chalkler = Chalkler.new
      chalkler.create_from_meetup(result, channel)
    else
      chalkler.update_from_meetup(result)
      chalkler.channels << channel unless chalkler.channels.exists? channel
    end
    chalkler
  end

  def create_from_meetup(result, channel)
    self.name = result.name
    self.meetup_id = result.id
    self.provider = 'meetup'
    self.uid = result.id
    self.bio = result.bio
    self.meetup_data = result.to_json
    self.join_channels = [ channel.id ]
    self.save!
  end

  def update_from_meetup(result)
    self.name = result.name
    self.bio = result.bio
    self.meetup_data = result.to_json
    self.save
  end

  private

  def set_from_meetup_data
    return unless meetup_data?
    self.created_at = Time.at(meetup_data["joined"] / 1000)
  end

  # for Chalklers created outside of meetup
  def set_reset_password_token
    return unless self.set_password_token
    self.password = Chalkler.reset_password_token
    self.reset_password_token = Chalkler.reset_password_token
    self.reset_password_sent_at = Time.now.utc
  end

end
