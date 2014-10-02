class ChannelPlan < ActiveRecord::Base
  attr_accessible *BASIC_ATTR = [ :name, :max_channel_admins, :max_teachers, :class_attendee_cost, :course_attendee_cost, :max_free_class_attendees, :annual_cost, :processing_fee_percent ]
  attr_accessible  *BASIC_ATTR, :as => :admin
  has_many :channels
  validates_uniqueness_of :name, allow_blank: false
  def self.default
    ChannelPlan.where(name: 'Community').first
  end

  def apply_custom(channel)
    self.id = nil
    self.name = channel.plan_name if channel.plan_name.present?

    self.admin_logins = channel.plan_max_channel_admins if channel.plan_max_channel_admins.present?

    self.class_attendee_cost = channel.plan_class_attendee_cost if channel.plan_class_attendee_cost.present?

    self.course_attendee_cost = channel.plan_course_attendee_cost if channel.plan_course_attendee_cost.present?

    self.max_free_class_attendees = channel.plan_max_free_class_attendees if  channel.plan_max_free_class_attendees.present?

    self.annual_cost = channel.plan_annual_cost if channel.plan_annual_cost.present?

    self.processing_fee_percent = channel.plan_processing_fee_percent if channel.plan_processing_fee_percent.present?

    self.max_teachers = channel.plan_max_teachers if channel.plan_max_teachers.present?
    self
  end
end