class ChannelTeacherPolicy < ApplicationPolicy

  def initialize(user, channel_teacher)
    @user = user
    @channel_teacher = channel_teacher
  end

  def new?
    @user.super? or @user.channels_adminable.include? @channel_teacher.channel
  end

  def show?
    true #TODO: implement incognito
  end

  def create?
    new?
  end

  def edit?
    admin?
  end

  def update?
    admin?
  end

  def admin?
    @user.super? or @user.channels_adminable.include? @channel_teacher.channel or @channel_teacher.chalkler == @user.chalkler
  end

end
