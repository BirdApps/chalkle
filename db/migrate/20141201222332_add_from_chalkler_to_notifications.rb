class AddFromChalklerToNotifications < ActiveRecord::Migration
  def change
    add_column :notification_preferences, :from_chalkler_id, :integer
    add_foreign_key :notification_preferences, :chalklers, name: 'notification_preferences_from_chalkler_id_fk'
  end
end
