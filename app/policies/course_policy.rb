class CoursePolicy < ApplicationPolicy
  attr_reader :user, :course

  def initialize(user, course)
    @user = user
    @course = course
  end

  def tiny_url?
    true
  end

  def bookings? 
    read? 
  end

  def bookings_csv?
    return false unless @user.super?
    read?
  end

  def edit?
    write?
  end

  def show?
    @course.displayable? or read?
  end

  def update?
    write?
  end

  def clone?
    write?(true)
  end

  def change_status?
    write?
  end

  def confirm_cancel?
    write?
  end

  def cancel?
    write?
  end

  def admin?
    @user.super? or @user.channel_admins.where(channel_id: @course.channel_id).present?
  end

  def write?(anytime=false)
    anytime = true if @course.status == "Draft"
    @user.super? or
     ((@user.channel_teachers.where(id: @course.teacher_id, can_make_classes: true).present? or 
      @user.channel_admins.where(channel_id: @course.channel_id).present?) and 
      (anytime ? true : (@course.end_at || @course.start_at) > DateTime.current))
  end

  def read?
    @user.super? or (@user.channel_teachers.where(id: @course.teacher_id).present? or @user.channel_admins.where(channel_id: @course.channel_id).present?)
  end
end