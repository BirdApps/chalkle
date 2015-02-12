require 'avatar_uploader'

class ProviderTeacher < ActiveRecord::Base
  mount_uploader :avatar, AvatarUploader

  EMAIL_VALIDATION_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  attr_accessible :provider, :provider_id, :chalkler, :chalkler_id, :name, :email, :bio, :pseudo_chalkler_email, :can_make_classes, :tax_number, :account, :avatar, :courses

  belongs_to  :provider
  belongs_to  :chalkler
  has_many    :courses, class_name: "Course", foreign_key: "teacher_id"
  has_many    :outgoing_payments, foreign_key: :teacher_id

  validates_uniqueness_of :chalkler_id, scope: :provider_id, allow_blank: true
  validates_presence_of :provider_id
  validates_presence_of :email, message: 'Email cannot be blank'
  validates :pseudo_chalkler_email, allow_blank: true, format: { with: EMAIL_VALIDATION_REGEX, :message => "That doesn't look like a real email"  }

  before_save :check_name
  after_save :expire_cache!

  def email
    unless chalkler.nil?
      chalkler.email
    else
      pseudo_chalkler_email
    end
  end

  def students
    courses.collect{ |course| course.chalklers }.flatten
  end

  def email=(email)
    self.chalkler = Chalkler.exists email
    self.pseudo_chalkler_email = email unless chalkler.present?
    #TODO: email chalkler or non-chalkler to tell them they are a teacher
  end

  def next_class
    courses.in_future.published.order(:start_at).first
  end

  def tax_registered?
    tax_number.present?
  end

  def check_name
    if self.name.blank?
      if chalkler
        self.name = chalkler.name
      elsif email
        self.name = email.split('@')[0]
      end
    end
  end

  def expire_cache!
    courses.each do |course|
      course.expire_cache!
    end
  end

  def bio 
    read_attribute :bio || "#{name} is a teacher for #{provider.name}" 
  end

  private 
    def method_missing(method, *args, &block)  
      chalkler.send(method, *args, &block)
    end  

end