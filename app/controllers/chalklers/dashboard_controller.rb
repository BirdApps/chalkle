class Chalklers::DashboardController < Chalklers::BaseController
  before_filter :authenticate_chalkler!, :except => [:index, :beta]
  before_filter :has_channel_membership?, :except => [:index, :beta]

  layout 'home', only: :beta

  def index
  end

  def beta
    @lessons = Lesson.with_region.upcoming.published.by_date.limit(4 * 6)
    @featured_channels = Channel.visible.limit(5).all
  end

  def settings
  	@chalkler_email_preferences = ChalklerPreferences.new(current_chalkler)
  end

  def missing_channel
    @channels = Channel.where{ :urlname != nil }
  end
end
