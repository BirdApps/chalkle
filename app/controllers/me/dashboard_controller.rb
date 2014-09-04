class Me::DashboardController < Me::BaseController

  def index
    @courses = Course.upcoming.published.by_date.not_meetup.limit(4 * 6)
    @featured_channels = Channel.visible.has_logo.limit(5).all
  end

  def settings
  	@chalkler_email_preferences = ChalklerPreferences.new(current_chalkler)
  end

  def bookings
    #TODO: show all bookings for that user
  end

  private

    def logged_out_only
      if current_chalkler
        redirect_to courses_path
        false
      end
    end
end
