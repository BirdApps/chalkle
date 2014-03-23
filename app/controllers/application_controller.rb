class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_ability
    @current_ability ||= Ability.new(current_admin_user)
  end

  def styleguide
    render "/styleguide"
  end

  def after_sign_in_path_for(resource)
    # stored_location_for(resource) || other_path
    # request.referrer
    return admin_root_path if resource.is_a? AdminUser
    session[:previous_url] || root_path
  end

  def after_register_path_for(resource)
    session[:previous_url] || root_path
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to admin_dashboard_path, :alert => exception.message
  end

  protected

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def default_url_options
    {subdomain: 'www'}
  end

  private

  def store_location
    session[:previous_url] = request.fullpath unless request=~ /\/chalklers/
  end
end
