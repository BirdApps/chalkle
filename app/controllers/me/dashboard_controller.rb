class Me::DashboardController < Me::BaseController
  before_filter :page_titles

  def index
    
  end

  def settings
  	@chalkler_email_preferences = ChalklerPreferences.new(current_chalkler)
  end

  def bookings
    #TODO: show all bookings for that user
  end

  private
    def page_titles
      @page_title = current_user.name
      @page_subtitle = 'Dashboard'
      @page_title_logo = current_user.avatar
    end

end
