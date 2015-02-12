class ProviderPlan < ActiveRecord::Base
  
  attr_accessible *BASIC_ATTR = [ :name, :max_provider_admins, :max_teachers, :class_attendee_cost, :course_attendee_cost, :max_free_class_attendees, :annual_cost, :processing_fee_percent ]
  
  attr_accessible  *BASIC_ATTR, :as => :admin
  
  has_many :providers

  validates_uniqueness_of :name, allow_blank: false
  
  def self.default
    ProviderPlan.where(name: 'Community').first
  end

  def apply_custom(provider)
    self.id = nil
    self.name = provider.plan_name if provider.plan_name.present?

    self.max_provider_admins = provider.plan_max_provider_admins if provider.plan_max_provider_admins.present?

    self.class_attendee_cost = provider.plan_class_attendee_cost if provider.plan_class_attendee_cost.present?

    self.course_attendee_cost = provider.plan_course_attendee_cost if provider.plan_course_attendee_cost.present?

    self.max_free_class_attendees = provider.plan_max_free_class_attendees if  provider.plan_max_free_class_attendees.present?

    self.annual_cost = provider.plan_annual_cost if provider.plan_annual_cost.present?

    self.processing_fee_percent = provider.plan_processing_fee_percent if provider.plan_processing_fee_percent.present?

    self.max_teachers = provider.plan_max_teachers if provider.plan_max_teachers.present?
    self
  end
end