class V2::BaseController < ApplicationController
  
  layout 'v2/layouts/v2_application'
  
  before_filter :the_user

  def not_found object="Page"

    raise ActionController::RoutingError.new("#{object} could not be found")
  end

  private
  def the_user
    if current_chalkler || current_admin_user
      @the_user = TheUser.new current_chalkler
    else
      @the_user = nil
    end
  end

end