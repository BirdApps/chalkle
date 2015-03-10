class ProviderPolicy < ApplicationPolicy

  def initialize(user, provider)
    @user = user
    @provider = provider
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

  def admins_index?
    read?
  end

  def resources?
    read?
  end

  def bookings?
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
    @user.super? or @user.providers_adminable.include? @provider
  end

  def read?
    @user.super? or @user.providers_adminable.include?(@provider) or @user.providers_teachable.include?(@provider)
  end

end
