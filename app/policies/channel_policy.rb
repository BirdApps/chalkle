class ChannelPolicy < ApplicationPolicy

  def initialize(user, channel)
    @user = user
    @course = channel
  end

  def edit?
    update?
  end

  def update?
    @user.super? or @user.chalkler.channels_adminable.include? @channel
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
