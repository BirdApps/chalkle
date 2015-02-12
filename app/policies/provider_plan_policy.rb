class ProviderPlanPolicy < ApplicationPolicy

  def initialize(user, provider_plan)
    @user = user
    @provider_plan = provider_plan
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
