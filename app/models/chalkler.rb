class Chalkler < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  attr_accessible :bio, :email, :meetup_data, :meetup_id, :name, :password, :password_confirmation, :remember_me,
    :channel_ids, :gst, :provider, :uid, :email_frequency, :email_categories, :email_streams

  validates_uniqueness_of :meetup_id, allow_blank: true
  validates :email, allow_blank: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }, uniqueness: { case_sensitive: false }
  validates_format_of :gst, allow_blank: true, with: /\A[\d -]+\z/

  has_many :channel_chalklers
  has_many :channels, :through => :channel_chalklers
  has_many :bookings
  has_many :lessons, :through => :bookings
  has_many :lessons_taught, class_name: "Lesson", foreign_key: "teacher_id"
  has_many :payments

  serialize :email_categories
  serialize :email_streams

  EMAIL_FREQUENCY_OPTIONS = %w(daily weekly monthly almost-never)

  before_create :set_from_meetup_data

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

  def set_from_meetup_data
    return if meetup_data.empty?
    self.created_at = Time.at(meetup_data["joined"] / 1000)
  end

  def self.create_from_meetup_hash(result, channel)
    c = Chalkler.find_or_initialize_by_meetup_id(result.id)
    c.name = result.name
    c.meetup_id = result.id
    c.provider = "meetup"
    c.uid = result.id
    c.bio = result.bio
    c.meetup_data = result.to_json
    c.save
    c.channels << channel unless c.channels.exists? channel
    c.valid?
  end

  def self.find_for_meetup_oauth(auth, signed_in_resource=nil)
    chalkler = Chalkler.where(:provider => auth.provider, :uid => auth.uid.to_s).first
      unless chalkler
        chalkler = Chalkler.create(name:auth.extra.raw_info.name,
                             provider:auth.provider,
                             uid:auth.uid.to_s,
                             meetup_id: auth.uid,
                             email:auth.info.email,
                             password:Devise.friendly_token[0,20]
                             )
      end
    chalkler
  end

end
