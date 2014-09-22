class ChalklerPolicy < ApplicationPolicy
  def initialize(user, chalkler)
    @user = user
    @chalkler = chalkler
  end

  def exists?
    @user.super? or current_user.channels_adminable.count > 0
  end
end