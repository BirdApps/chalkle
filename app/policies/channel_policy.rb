class ChannelPolicy < ApplicationPolicy

  def initialize(user, channel)
    @user = user
    @channel = channel
  end

  def teachers?
    true
  end

  def create?
    @user.authenticated?
  end

  def new?
    create?
  end

  def admins?
    read?
  end

  def resources?
    read?
  end

  def metrics?
    admin?
  end

  def edit?
    admin?
  end

  def cancel?
    can_be = false
    can_be = true if @course.min_attendee > @course.bookings.confirmed.count
    can_be = true if @course.start_at > DateTime.current.advance(hours: 24)
    can_be = true if @course.bookings.confirmed.blank?
    (can_be and admin?) or @user.super?
  end

  def update?
    admin?
  end

  def admin?
    @user.super? or @user.channels_adminable.include? @channel
  end

  def read?
    @user.super? or @user.channels_adminable.include?(@channel) or @user.channels_teachable.include?(@channel)
  end

end
