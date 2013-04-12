class Chalklers::PreferencesController < Chalklers::BaseController
  def save
   	@chalkler_email_preferences = ChalklerPreferences.new(current_chalkler)

      if @chalkler_email_preferences.update_attributes(params[:chalkler_preferences])
        redirect_to chalklers_meetup_email_settings_url, notice: 'Your preferences have been saved.'
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

  def update_email
    @chalkler = current_chalkler
    if params[:chalkler].blank?
      render template: 'chalklers/update_email'
    else
      if @chalkler.update_attributes(params[:chalkler])
        redirect_to root_url, notice: 'Your preferences have been saved.'
      else
        render template: 'chalklers/update_email'
      end
    end
  end
end
