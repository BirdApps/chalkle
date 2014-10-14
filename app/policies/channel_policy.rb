class ChannelPolicy < ApplicationPolicy

  def initialize(user, channel)
    @user = user
    @channel = channel
  end

  def edit?
    admin?
  end

  def update?
    admin?
  end

  def metrics?
    admin?
  end

  def resources?
    teach?
  end

  def teachers?
    true
  end

  def teach?
    @user.super? or @user.channels.include? @channel
  end

  def new?
    admin?
  end

  def admins?
    admin?
  end

  def admin?
    @user.super? or @user.channels_adminable.include? @channel
  end

end