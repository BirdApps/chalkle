class Chalklers::DashboardController < Chalklers::BaseController
  before_filter :authenticate_chalkler!, :except => [:index, :beta]
  before_filter :has_channel_membership?, :except => [:index, :beta]
  before_filter :logged_out_only, only: :index

  layout 'home', only: :index

  def index
    @courses = Course.upcoming.published.by_date.not_meetup.limit(4 * 6)
    @featured_channels = Channel.visible.has_logo.limit(5).all
  end

  def settings
  	@chalkler_email_preferences = ChalklerPreferences.new(current_chalkler)
  end

  def missing_channel
    @channels = Channel.where{ :urlname != nil }
  end

  private

    def logged_out_only
      if current_chalkler
        redirect_to courses_path
        false
      end
    end
end
