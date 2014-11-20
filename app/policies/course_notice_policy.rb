class CourseNoticePolicy < ApplicationPolicy

  def initialize(user, course_notice)
    @user = user
    @course_notice = course_notice
  end

  def show?
    @user.super? or @course_notice.visible
  end

  def create?
    @user.authenticated?
  end

  def update?
    @user.super? or @course_notice.chalkler.id == @user.id
  end

  def destroy?
    @user.super? or @course_notice.chalkler.id == @user.id or @user.courses_adminable.include?(@course_notice.course)
  end

end
