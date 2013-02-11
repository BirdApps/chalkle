class Chalklers::DashboardController < Chalklers::BaseController
  def index
  end

  def classes
  end

  def settings
  	@chalkler_email_preferences = ChalklerPreferences.new(current_chalkler)
  end
end
