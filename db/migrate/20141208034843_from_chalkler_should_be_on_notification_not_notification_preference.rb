class FromChalklerShouldBeOnNotificationNotNotificationPreference < ActiveRecord::Migration
  def up
    remove_column :notification_preferences, :from_chalkler_id

    add_column :notifications, :from_chalkler_id, :integer
    add_foreign_key :notifications, :chalklers, name: 'notifications_from_chalkler_id_fk'
  end

  def down  
    remove_column :notifications, :from_chalkler_id
  
    add_column :notification_preferences, :from_chalkler_id, :integer
    add_foreign_key :notification_preferences, :chalklers, name: 'notification_preferences_from_chalkler_id_fk'

  end
end
