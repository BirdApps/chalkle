class ChalklerPolicy < ApplicationPolicy

  def initialize(user, chalkler)
    @user = user
    @chalkler = chalkler
  end

  def index?
    true if @user.super?
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

  def delete?
    admin? || @chalkler.id == @user.id
  end

  def destroy?
    admin? || @chalkler.id == @user.id
  end

end