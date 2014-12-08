class AddOptionsToNotificationPreferences < ActiveRecord::Migration
  def change
    add_column :notification_preferences, :chalkler_discussion_from_chalkler, :bool, default: :true
    add_column :notification_preferences, :chalkler_discussion_from_teacher, :bool, default: :true
    add_column :notification_preferences, :teacher_bookings, :bool, default: :true
    add_column :notification_preferences, :teacher_discussion, :bool, default: :true
    add_column :notification_preferences, :provider_bookings, :bool, default: :true
    add_column :notification_preferences, :provider_discussion, :bool, default: :true
  end
end
