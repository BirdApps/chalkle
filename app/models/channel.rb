class Channel < ActiveRecord::Base
  attr_accessible :name, :url_name, :channel_percentage, :teacher_percentage, :chalkle_percentage

  validates :name, :presence => true
  validates :url_name, :presence => true
  validates :channel_percentage, :presence => true, :allow_blank => false, :numericality => { :less_than_or_equal_to => 1, :message => "Channel percentage of revenue must be less than or equal to 1"}
  validates :teacher_percentage, :presence => true, :allow_blank => false, :numericality => { :less_than_or_equal_to => 1, :message => "Teacher percentage of revenue must be less than or equal to 1"}
  validates :chalkle_percentage, :presence => true, :allow_blank => false, :numericality => { :less_than_or_equal_to => 1, :message => "Chalkle percentage of revenue must be less than or equal to 1"}
  validate :percentage_sum_validation

  has_many :channel_admins
  has_many :admin_users, :through => :channel_admins
  has_many :channel_chalklers
  has_many :chalklers, :through => :channel_chalklers
  has_many :channel_lessons
  has_many :lessons, :through => :channel_lessons
  has_many :bookings, :through => :lessons
  has_many :payments, :through => :bookings
  has_many :channel_categories
  has_many :categories, :through => :channel_categories

  def percentage_sum_validation
    return unless channel_percentage and teacher_percentage and chalkle_percentage
    errors.add(:channel_percentage, "Sum of revenue percentages must be less than or equal to 1") unless (channel_percentage + teacher_percentage + chalkle_percentage <= 1)
    errors.add(:teacher_percentage, "Sum of revenue percentages must be less than or equal to 1") unless (channel_percentage + teacher_percentage + chalkle_percentage <= 1)
    errors.add(:chalkle_percentage, "Sum of revenue percentages must be less than or equal to 1") unless (channel_percentage + teacher_percentage + chalkle_percentage <= 1)
  end

end
