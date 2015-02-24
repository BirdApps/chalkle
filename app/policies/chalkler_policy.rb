class ChalklerPolicy < ApplicationPolicy
  def initialize(user, chalkler)
    @user = user
    @chalkler = chalkler
  end


  def show?
    true
    #@user.super? or @chalkler.visible or @user.provider_teachers.collect{ |provider_teacher| provider_teacher.students }.flatten.include?(@chalkler) 
  end

end