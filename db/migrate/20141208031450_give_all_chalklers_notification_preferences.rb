class GiveAllChalklersNotificationPreferences < ActiveRecord::Migration
  include Rails.application.routes.url_helpers
  
  def up
    NotificationPreference.transaction do
      Chalkler.scoped.each do |chalkler|
        unless chalkler.notification_preference.present?
          notifier = NotificationPreference.create chalkler: chalkler
          chalkler.send_notification Notification::CHALKLE, me_preferences_notifications_path, "Hi! Notifications relevant to your activity on Chalkle will show up here from now on. We've also given you better control over what emails you would like to receive. **Email Preferences**"
        end
      end
    end
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
