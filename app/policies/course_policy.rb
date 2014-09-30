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
    @user.channel_teachers.include? @course.teacher or @user.channel_admins.where(channel_id: @course.channel_id).present? or @user.super?
  end

  def change_status?
    update?
  end

end