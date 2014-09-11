class AddMaxTeachersToChannelPlanAndPlanMaxTeachersToChannel < ActiveRecord::Migration
  def change
    add_column :channel_plans, :max_teachers, :integer
    add_column :channels, :plan_max_teachers, :integer
    rename_column :channel_plans, :max_admin_logins, :max_channel_admins
    rename_column :channels, :plan_max_admin_logins, :plan_max_channel_admins
  end
end
