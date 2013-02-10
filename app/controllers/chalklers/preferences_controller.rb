class Chalklers::PreferencesController < Chalklers::BaseController
    def save
    @chalkler_email_preferences = ChalklerPreferences.new(current_chalkler)

    if @chalkler_email_preferences.update_attributes(params[:chalkler_preferences])
      redirect_to root_url, notice: 'Your preferences have been saved.'
    else
      flash[:error] = 'There was a problem saving your preferences.'
      redirect_to :back
    end
  end
end
