class ChalklerPolicy < ApplicationPolicy
  def initialize(user, chalkler)
    @user = user
    @chalkler = chalkler
  end

  def exists?
    @user.super? or @user.channels_adminable.count > 0
  end

  def show?
    @user.super? or @chalkler.visible or @user.channel_teachers.collect{ |channel_teacher| channel_teacher.students }.flatten.include?(@chalkler) 
  end

end