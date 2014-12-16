class GiveAllChalklersNotificationPreferences < ActiveRecord::Migration
  include Rails.application.routes.url_helpers
  
  def up
    NotificationPreference.transaction do
      Chalkler.scoped.each do |chalkler|
        unless chalkler.notification_preference.present?
          notifier = NotificationPreference.create chalkler: chalkler
          chalkler.send_notification Notification::CHALKLE, me_notification_preference_path, "**Hello #{chalkler.first_name}!** We'll drop notifications here to help you keep track of your classes from now on. We've also given you better control over what emails you would like to receive. **Configure your Email Preferences now**."
        end
      end
    end
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
