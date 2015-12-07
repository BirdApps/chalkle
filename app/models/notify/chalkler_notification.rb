class Notify::ChalklerNotification < Notify::Notifier
  
  def initialize(chalkler, role = NotificationPreference::CHALKLER)
    @chalkler = chalkler
    @role = role
  end

  def welcome
    message = I18n.t('notify.chalkler.welcome', name: chalkler.first_name)

    chalkler.send_notification Notification::CHALKLE, me_preferences_path, message

    ChalklerMailer.delay.welcome(chalkler) 
  end

  def course_digest
    DigestMailer.delay.course_digest(chalkler)
  end

  private
    def chalkler
      @chalkler
    end
end
