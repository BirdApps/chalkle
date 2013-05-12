class Chalklers::DashboardController < Chalklers::BaseController
  before_filter :authenticate_chalkler!, :except => [:index]
  before_filter :has_channel_membership?, :except => [:index]

  def index
  end

  def settings
  	@chalkler_email_preferences = ChalklerPreferences.new(current_chalkler)
  end

  def missing_channel
    @channels = Channel.where{ :urlname != nil }
  end
end
