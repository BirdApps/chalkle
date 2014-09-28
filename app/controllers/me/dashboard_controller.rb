class Me::DashboardController < Me::BaseController

  def index
  @page_title = current_user.name
  @page_subtitle = 'Dashboard'
  @page_title_logo = current_user.avatar

    
  end

  def settings
  	@chalkler_email_preferences = ChalklerPreferences.new(current_chalkler)
  end

  def bookings
    #TODO: show all bookings for that user
  end

end
