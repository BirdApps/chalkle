class Chalklers::DashboardController < Chalklers::BaseController
  def index
    @chalkler_email_preferences = ChalklerPreferences.new(current_chalkler)
  end

  def classes
  end
end
