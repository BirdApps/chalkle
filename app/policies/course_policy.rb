class CoursePolicy < ApplicationPolicy
  attr_reader :user, :course

  def initialize(user, course)
    @user = user
    @course = course
  end

  def edit?
    update?
  end

  def update?
    @user.admin_user.super? or @user.chalkler.channel_teachers.include? @course.teacher or @user.chalkler.channel_admins.where(channel_id: @course.channel_id).present?
  end

  def change_status?
    update?
  end

end