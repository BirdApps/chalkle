class ApplicationController < ActionController::Base
  protect_from_forgery
  #before_filter :authenticate, only: [:styleguide]

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to admin_dashboard_path, :alert => exception.message
  end

  def current_ability
    @current_ability ||= Ability.new(current_admin_user)
  end

  def styleguide
    render "/styleguide"
  end

  protected
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == "chalkle" && password == "chalkleadmin123"
    end
  end
end
