class Notify::Notifier
  
  include Rails.application.routes.url_helpers

  def as(role)
    @role = role if NotificationPreference::ROLES.include? role
    self
  end

  def from(user)
    @current_user = user
    self
  end

  private
    
    def role
      @role
    end

    def current_user
      @current_user
    end

end