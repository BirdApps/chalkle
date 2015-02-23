class Me::DashboardController < Me::BaseController
  
  def index
    redirect_to chalkler_path(current_chalkler.id) and return
  end

  def settings
  	@chalkler_email_preferences = ChalklerPreferences.new(current_chalkler)
  end

end
