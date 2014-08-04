class ChalklerObserver < ActiveRecord::Observer

  def after_create(chalkler)
    send_welcome_mail(chalkler)
  end

  def send_welcome_mail(chalkler)
    return unless chalkler.email?
    if chalkler.reset_password_token?
      chalkler.reset_password_sent_at = Time.now.utc
      chalkler.save
    end
    ChalklerMailer.welcome(chalkler).deliver!
  end


end
