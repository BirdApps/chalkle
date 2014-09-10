class ChannelPlanPolicy < ApplicationPolicy
  def index
    true
    #false unless @user.admin_user.super?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
