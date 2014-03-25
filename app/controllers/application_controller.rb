class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_ability
    @current_ability ||= Ability.new(current_admin_user)
  end

  def styleguide
    render "/styleguide"
  end

  def after_sign_in_path_for(resource)
    return admin_root_path if resource.is_a?(AdminUser)

    from_path    = stored_location_for(resource)
    default_path = root_path
    options      = { from_path: from_path, default_path: default_path }

    Chalkler::DataCollection.new(resource, options).path_name
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
