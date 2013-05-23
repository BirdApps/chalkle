class ChalklerObserver < ActiveRecord::Observer

  def after_create(chalkler)
    create_channel_associations(chalkler)
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

  def create_channel_associations(chalkler)
    return unless chalkler.join_channels.is_a?(Array)
    chalkler.join_channels.each do |channel_id|
      chalkler.channels << Channel.find(channel_id)
    end
    chalkler.save!
  end

end
