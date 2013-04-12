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

  def enter_email
    @chalkler = current_chalkler
    if params[:chalkler].blank?
      render template: 'chalklers/enter_email'
    else
      @chalkler.email = params[:chalkler][:email]
      if @chalkler.save
        redirect_to root_url, notice: 'Welcome to chalkle! Sign in successful.'
      else
        render template: 'chalklers/enter_email'
      end
    end
  end
end
