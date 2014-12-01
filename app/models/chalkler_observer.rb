class ChalklerObserver < ActiveRecord::Observer

  def after_create(chalkler)
    notifier = NotificationPreference.create chalkler: chalkler
    notifier.welcome
  end

end
