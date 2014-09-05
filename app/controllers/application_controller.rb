class ApplicationController < ActionController::Base
  protect_from_forgery
  include Filters::FilterHelpers
  layout 'layouts/application'
  before_filter :nav_links
  after_filter :store_location

  def not_found object="Page"
    raise ActionController::RoutingError.new("#{object} could not be found")
  end


  def current_ability
    @current_ability ||= Ability.new(current_admin_user)
  end

  def styleguide
    render "/styleguide"
  end

  def after_sign_in_path_for(resource)
    return admin_root_path if resource.is_a?(AdminUser)
    
    original_path = stored_location_for(resource)
    default_path  = root_path
    options       = { original_path: original_path, default_path: default_path }

    Chalkler::DataCollection.new(resource, options).path

    original_path || params[:redirect_to]  || root_path
  end

  def after_register_path_for(resource)
    session[:previous_url] || root_path
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to admin_dashboard_path, :alert => exception.message
  end

  protected

  def authenticate_chalkler!
    session[:user_return_to] = request.fullpath
    super
  end

  def previous_url
    session[:previous_url] unless session[:previous_url].split('/')[1] == "chalklers"
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  private

  def store_location
    session[:previous_url] = request.fullpath unless request=~ /\/chalklers/
  end

  def current_user
    if @current_user.nil?
      @current_user = TheUser.new current_chalkler, current_admin_user
    end
    return @current_user 
  end

  def nav_links
    @nav_links = []
  end
  
  def course_nav_links
    @nav_links = [{text: "Classes", target: courses_path }, {text: "Categories", target: categories_path }, {text: "Providers", target: channels_path }]
  end

  def courses_for_time
    @courses_for_time ||= Querying::CoursesForTime.new courses_base_scope
  end

  def courses_base_scope
    apply_filter start_of_association_chain.published.by_date
  end

  def start_of_association_chain
    @channel ? @channel.courses : Course
  end

  def current_date
    return @current_date if @current_date.present?
    if params[:day]
      @current_date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    else
      @current_date = DateTime.now
    end
    @current_date
  end

  def get_current_week( start_date = Date.today )
    Week.containing current_date
  end


end