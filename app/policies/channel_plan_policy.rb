class ChannelPlanPolicy < ApplicationPolicy

  def initialize(user, channel_plan)
    @user = user
    @channel_plan = channel_plan
  end

  def index?
    admin?
  end

  def show?
    admin?
  end

  def edit?
    admin?
  end

  def update?
    admin?
  end


  class Scope < Scope
    def resolve
      scope
    end
  end
end
