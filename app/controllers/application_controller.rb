class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery
  layout 'layouts/application'
  before_filter :load_region
  before_filter :load_channel
  before_filter :load_category

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
    stored_location_for(resource) || params[:redirect_to]  || root_path
  end

  def about

  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to admin_dashboard_path, :alert => exception.message
  end

  protected

    def authorize(record)
      super record unless current_user.super?
    end

    def check_clear_filters
      if @region.id.blank?
        session[:region] = nil
      end
      if @category.id.blank?
        session[:topic] = nil
      end
      if @channel.id.blank?
        session[:provider] = nil
      end
    end

    def expire_filter_cache
      expire_fragment('category_filter_list')
      expire_fragment('region_filter_list')
      expire_fragment('channel_filter_list')
    end

    def authenticate_chalkler!
      session[:user_return_to] = request.fullpath
      super
    end

    def current_user
      if @current_user.nil?
        @current_user = TheUser.new current_chalkler, current_admin_user
      end
      return @current_user 
    end

    def not_found
      raise ActionController::RoutingError.new('Not Found')
    end

    def load_country
      if country_code
        if country_code != 'nz'
          raise ActiveRecord::RecordNotFound
        end
      end
    end

    def country_code
      params[:country_code] unless params[:country_code].blank?
    end
    
    def region_name
      session[:region] = params[:region] unless params[:region].blank?
      request_region = request.location.data["region_name"]
      request_region = nil unless request_region != ""
      session[:region] || request_region
    end

    def channel_name
      (params[:provider] || params[:channel_url_name]).encode("UTF-8", "ISO-8859-1").parameterize if (params[:provider] || params[:channel_url_name]).present?
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

    def load_channel
      redirect_to_subdomain
      if !@channel
        if channel_name 
          @channel = Channel.find_by_url_name(channel_name) || Channel.new(name: "All Providers")
        elsif params[:channel_id].present?
          @channel = Channel.find(params[:channel_id])
        end
      end
      if !@channel
        @channel = Channel.new(name: "All Providers")
      end
    end

    def redirect_to_subdomain
      if request.subdomain.present?
        redirect_to base_url+'/'+request.subdomain
      end
    end

    def courses_for_time
      @courses_for_time ||= Querying::CoursesForTime.new courses_base_scope
    end

    def courses_base_scope
      apply_filter start_of_association_chain.published.by_date
    end

    def check_presence_of_courses
      unless @courses.present?
        add_response_notice(notice)
      end
    end

    def add_response_notice(notice = nil)
        if response[:notices].nil?
          response[:notices] = []
        end
        response[:notices] << notice || "There are no courses that match the current filter"
    end

    def start_of_association_chain
      @channel.id.present? ? @channel.courses : Course
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

    def get_current_month
      @month = if params[:year] && params[:month]
        Month.new(params[:year].to_i, params[:month].to_i)
      else
        Month.current
      end
    end

    def base_url
      request.protocol + request.domain + (request.port.nil? ? '' : ":#{request.port}")
    end
end