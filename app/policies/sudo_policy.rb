class SudoPolicy < ApplicationPolicy
  attr_reader :user, :sudo

  def initialize(user, sudo)
    @user = user
    @booking = sudo
  end

  def index?
    true if @user.super?
  end

  def pay?
    index?
  end
end