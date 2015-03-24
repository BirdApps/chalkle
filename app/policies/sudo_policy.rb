class SudoPolicy < ApplicationPolicy
  attr_reader :user, :sudo

  def initialize(user, sudo)
    @user = user
    @booking = sudo
  end

  def super?
    @user.super?
  end

end