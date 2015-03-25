class ChannelToProvider < ActiveRecord::Migration
  def change
    transaction do
      rename_column :channel_admins, :channel_id, :provider_id
      rename_table :channel_admins, :provider_admins
      
      rename_column :channel_categories, :channel_id, :provider_id
      rename_table :channel_categories, :provider_categories
      
      rename_column :channel_contacts, :channel_id, :provider_id
      rename_table :channel_contacts, :provider_contacts
      
      rename_column :channel_course_suggestions, :channel_id, :provider_id
      rename_table :channel_course_suggestions, :provider_course_suggestions

      rename_column :channel_courses, :channel_id, :provider_id
      rename_table :channel_courses, :provider_courses

      rename_column :channel_photos, :channel_id, :provider_id
      rename_table :channel_photos, :provider_photos

      rename_column :channel_plans, :max_channel_admins, :max_provider_admins
      rename_table :channel_plans, :provider_plans

      rename_column :channel_regions, :channel_id, :provider_id
      rename_table :channel_regions, :provider_regions

      rename_column :channel_teachers, :channel_id, :provider_id
      rename_table :channel_teachers, :provider_teachers

      rename_column :channels, :channel_rate_override, :provider_rate_override
      rename_column :channels, :channel_plan_id, :provider_plan_id
      rename_column :channels, :plan_max_channel_admins, :plan_max_provider_admins
      rename_table :channels, :providers

      rename_column :courses, :channel_id, :provider_id
      rename_column :courses, :channel_payment_id, :provider_payment_id

      rename_column :outgoing_payments, :channel_id, :provider_id

      rename_column :subscriptions, :channel_id, :provider_id
    end
  end
end
