class NotificationPolicy < ApplicationPolicy
  attr_reader :user, :notification

  def initialize(user, notification)
    @user = user
    @notification = notification
  end

  def show?
    user.super? or (notification.chalkler.id == user.id and notification.visible?)
  end
end