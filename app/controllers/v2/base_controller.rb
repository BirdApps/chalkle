class V2::BaseController < ApplicationController
  
  layout 'v2/layouts/v2_application'
  
  before_filter :nav_links

  def not_found object="Page"
    raise ActionController::RoutingError.new("#{object} could not be found")
  end

  private

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
    @nav_links = [{text: "Classes", target: v2_courses_path }, {text: "Categories", target: v2_categories_path }, {text: "Providers", target: v2_channels_path }]
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

  def get_current_week( start_date = Date.today )
    if params[:day]
      Week.containing Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    else
      Week.containing start_date
    end
  end

end