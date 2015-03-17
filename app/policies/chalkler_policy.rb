class ChalklerPolicy < ApplicationPolicy
  def initialize(user, chalkler)
    @user = user
    @chalkler = chalkler
  end

  def show?
    true
  end

  def admin?
    @user.id == @chalkler.id || @user.super?
  end

  def edit?
    admin?
  end

end