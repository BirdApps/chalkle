class AddChannelPlanOverridesToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :plan_name, :string
    add_column :channels, :plan_max_admin_logins, :integer
    add_column :channels, :plan_max_free_class_attendees, :integer
    add_column :channels, :plan_class_attendee_cost, :decimal
    add_column :channels, :plan_course_attendee_cost, :decimal
    add_column :channels, :plan_annual_cost, :decimal
    add_column :channels, :plan_processing_fee_percent, :decimal
  end
end
