class Me::DashboardController < Me::BaseController

  def index
    
  end

  def settings
  	@chalkler_email_preferences = ChalklerPreferences.new(current_chalkler)
  end

  def bookings
    #TODO: show all bookings for that user
  end

end
