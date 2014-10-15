class NilClassPolicy < ApplicationPolicy
  attr_reader :user, :nil_class

  def initialize(user, nil_class)
    raise Pundit::NotDefinedError, "Resource cannot be found"
    @user = user
    @nil_class = nil_class
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    false
  end

  def update?
    false
  end

  def edit?
    false
  end

  def destroy?
    false
  end

  def scope
    false
  end

  def admin?
    false
  end

end

