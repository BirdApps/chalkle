class ProviderTeacherPolicy < ApplicationPolicy

  def initialize(user, provider_teacher)
    @user = user
    @provider_teacher = provider_teacher
  end

  def new?
    @user.super? or @user.providers_adminable.include? @provider_teacher.provider
  end

  def show?
    true #TODO: implement incognito
  end

  def create?
    new?
  end

  def edit?
    admin?
  end

  def update?
    admin?
  end

  def admin?
    @user.super? or @user.providers_adminable.include? @provider_teacher.provider or @provider_teacher.chalkler == @user.chalkler
  end

end
