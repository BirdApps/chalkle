class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery
  rescue_from Pundit::NotAuthorizedError, with: :permission_denied
  rescue_from Pundit::NotDefinedError, with: :not_found
  
  layout 'layouts/application'

  before_filter :set_locale
  before_filter :load_provider
  before_filter :check_user_data
  after_filter :store_location, except: :set_redirect

  def styleguide
    render "/styleguide"
  end

  def home
    @hero = ActionController::Base.helpers.image_path('teach/reward.jpg')
    @header_partial = '/layouts/headers/home'
    @providers = Provider.promotable_within_coordinates({lat: -36.0, long: 170.0}, {lat: -34.0, long: 180.0})                                                  
  end

  def color_scheme
    not_found unless current_user.super?
  end

  def not_found
    @not_found = true
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  def set_redirect
    path = params[:redirect_to]
    unless (path == new_chalkler_session_path        ||
            path == new_chalkler_registration_path   ||
            path == chalkler_omniauth_authorize_path(:facebook) )
      session[:previous_url] = path
    end
    render json: { previous_url:  session[:previous_url] }
  end

protected
  
  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    return if @not_found
    return unless request.get?
    return if request.xhr?
    unless (request.path == root_path                        ||
            request.path == new_chalkler_session_path        ||
            request.path == chalkler_session_path            ||
            request.path == new_chalkler_registration_path   ||
            request.path == chalkler_registration_path       ||
            request.path == accept_chalkler_invitation_path  ||
            request.path == remove_chalkler_invitation_path  ||
            request.path == chalkler_invitation_path         ||
            request.path == new_chalkler_invitation_path     ||
            request.path == chalkler_omniauth_authorize_path(:facebook) )
      session[:previous_url] = request.fullpath 
    end
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || classes_path
  end

  def after_register_path_for(resource)
     session[:previous_url] || classes_path
  end

  def authenticate_chalkler!
    session[:user_return_to] = request.fullpath
    super
  end

  def current_user
    @current_user ||= TheUser.new current_chalkler
  end

  def permission_denied
    add_flash :warning, "You do not have permission to view that page"
    unless current_user.authenticated?
      authenticate_chalkler!
    else
      redirect_to root_url
    end
  end

  def check_course_visibility
    unless !@course || policy(@course).read?
      unless Course::PUBLIC_STATUSES.include? @course.status
        add_flash :warning, "This class is no longer available."
        redirect_to :root
        return false
      end
    end
  end

  def redirect_to_subdomain
    if request.subdomain.present?
      redirect_to request.protocol + request.domain + (request.port.nil? ? '' : ":#{request.port}") +'/'+request.subdomain
    end
  end


  def current_date
    return @current_date if @current_date.present?
    if params[:day]
      begin
        @current_date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
      rescue
        @current_date = DateTime.current
      end
    else
      @current_date = DateTime.current
    end
    @current_date
  end

  def get_current_week( start_date = Date.current )
    Week.containing current_date
  end

  def get_current_month
    @month = if params[:year] && params[:month]
      Month.new(params[:year].to_i, params[:month].to_i)
    else
      Month.current
    end
  end

  def entity_events
    auto_log = true
    EntityEvents.record(request, current_chalkler, auto_log)
  end

  def set_locale
    locale = params[:locale].encode("UTF-8", "ISO-8859-1") if params[:locale].present?
    unless locale.present? && I18n.available_locales.include?(locale.to_sym)
      locale = extract_locale_from_tld
      unless locale.present? && I18n.available_locales.include?(locale.to_sym)
        locale = I18n.default_locale
      end
    end
    I18n.locale = locale
  end

  def extract_locale_from_tld
    parsed_locale = request.host.split('.').last
    I18n.available_locales.map(&:to_s).include?(parsed_locale) ? parsed_locale : nil
  end

  def check_user_data
    if current_user.authenticated?
      if current_user.email.nil?
        session[:original_path] = request.path
        return redirect_to me_enter_email_path
      end
    end
  end

  def flash_errors(errors)
    errors.map { |k,v| add_flash(:error, "** #{k} ** - #{v}") }
  end

  def add_flash(message_type, message)
    #message_type should be one of [:success,:info,:warning,:error]
    flash[message_type] = [] if flash[message_type].nil?
    flash[message_type] << message
  end

  def provider_name
    @provider_name ||= params[:provider_url_name].encode("UTF-8", "ISO-8859-1").parameterize if params[:provider_url_name].present?
    rescue ArgumentError 
      nil
  end

  def load_provider
    redirect_to_subdomain
    if !@provider
      if params[:provider_id].present?
        @provider = Provider.find(params[:provider_id])
      elsif provider_name
        @provider = Provider.find_by_url_name(provider_name)
      end
    end
  end

  def load_course
    @course = Course.find_by_id(params[:course_id] || params[:id])
    not_found and return unless @course
    authorize @course, :show?
    @provider = @course.provider
  end

  def header_provider
    if @provider
      @hero = @provider.hero
      if @provider.header_color
        @header_color = @provider.header_color(:rgba)
        @header_color_opaque = @provider.header_color(:hex)
      end
      @header_partial = '/layouts/headers/provider'
    end
  end

  def header_chalkler
    if @chalkler
      @header_partial = '/layouts/headers/chalkler'
    end
  end

  def sidebar_administrate_chalkler
    if @chalkler && policy(@chalkler).admin?
      @sidebar_title = @chalkler.name
      @sidebar = '/layouts/sidebars/chalkler'
    end
  end

  def sidebar_administrate_provider
    load_provider unless @provider
    if @provider && policy(@provider).admin?
      @sidebar = '/layouts/sidebars/provider'
      @sidebar_title = @provider.name
    end
  end

  def sidebar_administrate_course
    load_course unless @course
    if @course && policy(@course).admin? 
      @sidebar_title = @course.name
      @sidebar = '/layouts/sidebars/course'
    end
  end

end