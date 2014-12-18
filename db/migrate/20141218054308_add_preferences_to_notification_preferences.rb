class AddPreferencesToNotificationPreferences < ActiveRecord::Migration
  def change
    add_column :notification_preferences, :preferences, :text
  end
end
