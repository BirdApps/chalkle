class ChannelAdminPolicy < ApplicationPolicy

  def initialize(user, channel_admin)
    @user = user
    @channel_admin = channel_admin
  end

  def create?
    admin?
  end

  def new?
    create?
  end

  def edit?
    update?
  end

  def update?
    admin?
  end

  def admin?
    @user.super? or @user.channels_adminable.include? @channel_admin.channel
  end

end
