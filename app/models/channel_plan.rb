class ChannelPlan < ActiveRecord::Base
  include Calculators
  attr_accessible *BASIC_ATTR = [ :name, :admin_logins, :class_attendee_cost, :course_attendee_cost, :max_free_class_attendees, :annual_cost ]
  has_many :channels

  def default
    ChannelPlan.first
  end

  def cost_calculator(channel,course)
    ChannelPlanCalculator(channel,course)
  end
end