class V2::BaseController < ApplicationController
  
  layout 'v2/layouts/v2_application'
  
  before_filter :nav_links
  before_filter :the_user

  def not_found object="Page"
    raise ActionController::RoutingError.new("#{object} could not be found")
  end

  private

  def the_user
    @the_user = TheUser.new current_chalkler, current_admin_user
  end

  def nav_links
    @nav_links = []
  end
  
  def course_nav_links
    @nav_links = [{text: "Classes", target: v2_courses_path }, {text: "Categories", target: v2_categories_path }, {text: "Channels", target: v2_channels_path }]
  end

end