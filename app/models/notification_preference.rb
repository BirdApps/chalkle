class NotificationPreference < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  
  attr_accessible *BASIC_ATTR = [:chalkler, :chalkler_id]
  
  belongs_to :chalkler

  def welcome
    chalkler.notify Notification::CHALKLE, me_preferences_path, "**Welcome!** It's great to have you onboard. When you are ready, pop over to your **Preferences** page to complete out your profile"
    ChalklerMailer.welcome(chalkler).deliver!
  end

end