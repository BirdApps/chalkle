class SudoPolicy < ApplicationPolicy
  attr_reader :user, :sudo

  def initialize(user, sudo)
    @user = user
    @booking = sudo
  end

  def index?
    @user.super?
  end

  def become?
    @user.super?
  end

end