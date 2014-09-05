class ApplicationController < ActionController::Base
  protect_from_forgery
  include Filters::FilterHelpers
  
  layout 'layouts/application'

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

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to admin_dashboard_path, :alert => exception.message
  end

  protected

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

    def load_region
      if region_name
        @region = Region.find_by_url_name(region_name)
        raise ActiveRecord::RecordNotFound unless @region
      end
    end

    def region_name
      params[:region] unless params[:region].blank?
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

    def get_current_month
      @month = if params[:year] && params[:month]
        Month.new(params[:year].to_i, params[:month].to_i)
      else
        Month.current
      end
    end
end