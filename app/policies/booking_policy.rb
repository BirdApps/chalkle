class BookingPolicy < ApplicationPolicy
  attr_reader :user, :booking

  def initialize(user, booking)
    @user = user
    @booking = booking
  end

  def edit?
     admin?
  end

  def update?
    admin?
  end

  def admin?
    @user.channel_teachers.where(id: @booking.course.teacher_id).present? or @user.channel_admins.where(channel_id: @booking.course.channel_id).present? or @booking.chalkler == @user.chalkler or @user.super?
  end

  def cancel?
    admin?
  end

  def confirm_cancel?
    admin?
  end

  def cancel?
    admin?
  end

end