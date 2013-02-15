class Chalkler < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  attr_accessible :bio, :email, :meetup_data, :meetup_id, :name, :password, :password_confirmation, :remember_me,
    :group_ids, :gst, :provider, :uid, :email_frequency, :email_categories, :email_streams

  validates_uniqueness_of :meetup_id, allow_blank: true
  validates :email, allow_blank: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }, uniqueness: { case_sensitive: false }
  validates_format_of :gst, allow_blank: true, with: /\A[\d -]+\z/

  has_many :group_chalklers
  has_many :groups, :through => :group_chalklers
  has_many :bookings
  has_many :lessons, :through => :bookings
  has_many :lessons_taught, class_name: "Lesson", foreign_key: "teacher_id"
  has_many :payments

  serialize :email_categories
  serialize :email_streams

  EMAIL_FREQUENCY_OPTIONS = %w(daily weekly)

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

  def lesson_filter(chalkler,lessons)
    filtered_lessons = lessons.find(:all, :conditions => ["category_id IN (?)", chalkler.email_categories] )
    if filtered_lessons.count == 0
      if chalkler.email_frequency == "daily"
        return lessons.find(:all, :limit => 5)
      elsif chalkler.email_frequency == "weekly"
        return lessons.find(:all, :limit => 10)
      end
    else
      return filtered_lessons
    end
  end

  def filtered_new_lessons
    if self.email_frequency == "daily"
      lesson_filter(self,Lesson.visible.where("created_at >= current_date - 1 AND created_at <= current_date"))
    elsif self.email_frequency == "weekly"
      lesson_filter(self,Lesson.visible.where("created_at >= current_date - 7 AND created_at <= current_date"))
    end
  end

  def filtered_still_open_lessons
    if self.email_frequency == "daily"
      lesson_filter(self,Lesson.visible.where("start_at >= current_date + 1 AND start_at <= current_date + 3"))
    elsif self.email_frequency == "weekly"
      lesson_filter(self,Lesson.visible.where("start_at >= current_date + 1 AND start_at <= current_date + 7"))
    end
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

  def self.create_from_meetup_hash(result, group)
    c = Chalkler.find_or_initialize_by_meetup_id(result.id)
    c.name = result.name
    c.meetup_id = result.id
    c.provider = "meetup"
    c.uid = result.id
    c.bio = result.bio
    c.meetup_data = result.to_json
    c.save
    c.groups << group unless c.groups.exists? group
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
