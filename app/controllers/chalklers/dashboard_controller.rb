class Chalklers::DashboardController < Chalklers::BaseController
  def index
  end

  def settings
  	@chalkler_email_preferences = ChalklerPreferences.new(current_chalkler)
  end

  def missing_channel
  end
end
