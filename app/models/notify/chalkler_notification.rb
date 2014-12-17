class Notify::ChalklerNotification < Notify::Notifier

  include Rails.application.routes.url_helpers

  def initialize(chalkler, role = NotificationPreference::CHALKLER)
    @chalkler = chalkler
    @role = role
  end

  def welcome
    message = I18n.t('notify.chalkler.welcome', name: chalkler.first_name)

    chalkler.send_notification Notification::CHALKLE, me_preferences_path, message

    ChalklerMailer.welcome(chalkler).deliver!
  end


  private
    def chalkler
      @chalkler
    end
end
