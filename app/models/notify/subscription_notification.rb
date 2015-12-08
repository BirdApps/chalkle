class Notify::SubscriptionNotification < Notify::Notifier
  
  def initialize(subscription, role = NotificationPreference::CHALKLER)
    @subscription = subscription
    @role = role
  end

  def subscribed_to(provider, subscribed_by)
    if subscription.chalkler?
      subscription.chalkler.send_notification Notification::FOLLOWING, provider_path(provider), "#{subscribed_by.name} added you as a follower of #{provider.name}", subscription
    else
      Chalkler.invite!( {email: subscription.pseudo_chalkler_email}, subscribed_by )
    end
  end


  private
 
  def subscription
    @subscription
  end

end
