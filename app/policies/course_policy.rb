class CoursePolicy < ApplicationPolicy
  attr_reader :user, :course

  def initialize(user, course)
    @user = user
    @course = course
  end

  def edit?
    update?
  end

  def show?
    @course.displayable? or admin?
  end

  def update?
    #cannot update if there are bookings unless you are an admin
    ((@user.channel_teachers.where(id: @course.teacher_id).present? or @user.channel_admins.where(channel_id: @course.channel_id).present?) and @course.bookings.empty? ) or @user.super?
  end

  def admin?
    @user.channel_teachers.where(id: @course.teacher_id).present? or @user.channel_admins.where(channel_id: @course.channel_id).present? or @user.super?
  end

  def change_status?
    update?
  end

  def confirm_cancel?
    admin?
  end

  def cancel?
    admin?
  end

end