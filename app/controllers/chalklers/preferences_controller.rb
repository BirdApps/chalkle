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

  def update_email
    render template: 'chalklers/update_email'
  end
end
