class CreateNotificationPreferences < ActiveRecord::Migration
  def change
    create_table :notification_preferences do |t|
      t.integer  :chalkler_id
      t.timestamps
    end
    add_foreign_key :notification_preferences, :chalklers, name: 'notification_preferences_chalkler_id_fk'
  end
end
