class BookingPolicy < ApplicationPolicy
  attr_reader :user, :booking

  def initialize(user, booking)
    @user = user
    @booking = booking
  end

  def admin?
    @user.provider_teachers.where(id: @booking.course.teacher_id).present? or @user.provider_admins.where(provider_id: @booking.course.provider_id).present? or @booking.chalkler == @user.chalkler or @user.super?
  end

  def cancel?
    admin?
  end

  def confirm_cancel?
    admin?
  end

  def take_rights?
    @user == @booking.booker
  end

  def cancel?
    admin?
  end

  def resend_receipt?
    admin? || (user == booking.booker)
  end

  def take_rights?
    @user == @booking.booker
  end

  def csv
    
  end

end