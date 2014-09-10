class ChannelPlan < ActiveRecord::Base
  attr_accessible *BASIC_ATTR = [ :name, :max_admin_logins, :class_attendee_cost, :course_attendee_cost, :max_free_class_attendees, :annual_cost, :processing_fee_percent ]
  has_many :channels

  def default
    ChannelPlan.first
  end

  def cost_calculator
    Finance::ChannelPlanCalculator.new self
  end

  def apply_custom(channel)
    name = channel.plan_name if channel.plan_name.present?

    admin_logins = channel.plan_admin_logins if channel.plan_admin_logins.present?

    class_attendee_cost = channel.plan_class_attendee_cost if channel.plan_class_attendee_cost.present?

    course_attendee_cost = channel.plan_course_attendee_cost if channel.plan_course_attendee_cost.present?

    max_free_class_attendees = channel.plan_max_free_class_attendees if  channel.plan_max_free_class_attendees.present?

    annual_cost = channel.plan_annual_cost if channel.plan_annual_cost.present?

    processing_fee_percent = channel.plan_processing_fee_percent if channel.plan_processing_fee_percent.present?
  end
end