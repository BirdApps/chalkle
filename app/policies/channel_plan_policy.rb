class ChannelPlanPolicy < ApplicationPolicy

  def initialize(user)
    raise Pundit::NotAuthorizedError, "You do not have the required permissions"
    @user = user
  end

  def index?
    if @user.admin_user.super?
      true 
    else
      false
    end
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
