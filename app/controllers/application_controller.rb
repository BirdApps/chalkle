class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery
  rescue_from Pundit::NotAuthorizedError, with: :permission_denied
  rescue_from Pundit::NotDefinedError, with: :not_found
  
  layout 'layouts/application'

  before_filter :set_locale

  before_filter :load_region
  before_filter :load_provider
  before_filter :load_category
  before_filter :skip_cache!
  before_filter :check_user_data
  after_filter :store_location

  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    return unless request.get? 
    if (request.path != "/chalklers/sign_in" &&
        request.path != "/chalklers/sign_up" &&
        request.path != "/chalklers/password/new" &&
        request.path != "/chalklers/password/edit" &&
        request.path != "/chalklers/confirmation" &&
        request.path != "/chalklers/sign_out" &&
        !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.fullpath 
    end
  end

  def after_sign_in_path_for(resource)
    Chalkler::DataCollection.new(resource, { original_path: session[:previous_url], default_path: root_path }).path

    session[:previous_url] || root_path
  end
  def styleguide
    render "/styleguide"
  end

  def after_register_path_for(resource)
    stored_location_for(resource) || params[:redirect_to]  || root_path
  end

  def about

  end


  def not_found
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

protected

  def authorize(record)
    super record unless current_user.super?
  end


  def authenticate_chalkler!
    session[:user_return_to] = request.fullpath
    super
  end

  def current_user
    @current_user ||= TheUser.new current_chalkler
  end

  def permission_denied
    flash[:notice] = "You do not have permission to view that page"
    unless current_user.authenticated?
      authenticate_chalkler!
    else
      redirect_to root_url
    end
  end

  def check_course_visibility
    unless !@course || policy(@course).read?
      unless Course::PUBLIC_STATUSES.include? @course.status
        flash[:notice] = "This class is no longer available."
        redirect_to :root
        return false
      end
    end
  end

  def country_code
    params[:country_code] unless params[:country_code].blank?
  end
  
  def region_name
    reconnect_attempts ||= 3
    session[:region] = params[:region] unless params[:region].blank?

    return session[:region] if session[:region]

    # Occasionally the geolocator API does not respond. Trying again usually gets this to behave.
    begin
      if request && request.location && request.location.data
        request_region = request.location.data["region_name"]
      end
    rescue 
      retry if (reconnect_attempts -=1) > 0
    else
      nil
    end
    (request_region == "") ? nil : request_region
  end
  def provider_name
    (params[:provider] || params[:provider_url_name]).encode("UTF-8", "ISO-8859-1").parameterize if (params[:provider] || params[:provider_url_name]).present?
  rescue ArgumentError 
    nil
  end

  def category_name
    params[:topic]
  end

  def load_region
    if @region.nil?
      @region = Region.new name: "New Zealand"
    end
  end

  def load_category
    if @category.nil?
      @category = Category.new name: 'All Topics'
    end
  end

  def load_provider
    redirect_to_subdomain
    if !@provider
      if provider_name 
        @provider = Provider.find_by_url_name(provider_name) || Provider.new(name: "All Providers")
      elsif params[:provider_id].present?
        @provider = Provider.find(params[:provider_id])
      end
    end
    if !@provider
      @provider = Provider.new(name: "All Providers")
    end
  end

  def redirect_to_subdomain
    if request.subdomain.present?
      redirect_to request.protocol + request.domain + (request.port.nil? ? '' : ":#{request.port}") +'/'+request.subdomain
    end
  end

  def add_response_notice(notice = nil)
      if response[:notices].nil?
        response[:notices] = []
      end
      response[:notices] << notice || "There are no courses that match the current filter"
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

  def expire_cache!
    CacheManager.expire_cache!
  end

  def skip_cache!
    expire_cache! if params[:skip_cache].present?
  end

  def expire_filter_cache!
    expire_fragment(/.*filter_list.*/)
  end


  def entity_events
    auto_log = true
    EntityEvents.record(request, current_chalkler, auto_log)
  end

  def set_locale
    I18n.locale = params[:locale] || extract_locale_from_tld || I18n.default_locale
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

end