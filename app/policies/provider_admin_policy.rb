class ProviderAdminPolicy < ApplicationPolicy

  def initialize(user, provider_admin)
    @user = user
    @provider_admin = provider_admin
  end

  def create?
    admin?
  end

  def new?
    create?
  end
  
  def show?
    @provider_admin.provider.teaching_chalklers.include?(@user.chalkler) || admin?
  end

  def edit?
    update?
  end

  def update?
    admin?
  end

  def admin?
    @user.super? or @user.providers_adminable.include? @provider_admin.provider
  end

end
