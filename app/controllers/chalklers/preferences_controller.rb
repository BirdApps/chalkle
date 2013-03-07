class Chalklers::PreferencesController < Chalklers::BaseController
  def save
   	@chalkler_email_preferences = ChalklerPreferences.new(current_chalkler)

      if @chalkler_email_preferences.update_attributes(params[:chalkler_preferences])
        redirect_to root_url, notice: 'Your preferences have been saved.'
      else
      render template: 'chalklers/dashboard/index'
      end
  end

  def show
    @chalkler_email_preferences = ChalklerPreferences.new(current_chalkler)

    render template: 'chalklers/dashboard/settings'
  end

  def meetup_email_settings
    render 'chalklers/dashboard/meetup_email_settings'
  end
end
