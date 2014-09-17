class ChannelPolicy < ApplicationPolicy

  def initialize(user, channel)
    @user = user
    @channel = channel
  end

  def edit?
    update?
  end

  def update?
    @user.super? or @user.chalkler.channels_adminable.include? @channel
  end

  def metrics?
    update?
  end

  def resources?
    update?
  end

end
