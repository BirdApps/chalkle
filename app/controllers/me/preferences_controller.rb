class Me::PreferencesController < Me::BaseController
  def save
   	@chalkler_email_preferences = ChalklerPreferences.new(current_chalkler)

    if @chalkler_email_preferences.update_attributes(params[:chalkler_preferences])
      redirect_to me_preferences_path, notice: 'Your preferences have been saved.'
    else
      render template: 'me/dashboard/index'
    end
  end

  def show
    @chalkler_email_preferences = ChalklerPreferences.new(current_chalkler)

    render template: 'me/preferences/settings'
  end

  def meetup_email_settings
    render 'me/preferences/meetup_email_settings'
  end

  def enter_email
    @chalkler = current_chalkler
    if params[:chalkler].blank?
      render template: 'me/preferences/enter_email'
    else
      @chalkler.email = params[:chalkler][:email]
      if @chalkler.save
        redirect_to :root, notice: 'Welcome to chalkle! Sign in successful.'
      else
        render template: 'me/preferences/enter_email'
      end
    end
  end

  def destroy
    @chalkler = Chalkler.find params[:id]

    if current_chalkler != @chalkler
      return redirect_to :root 
    end

    if @chalkler.destroy 
      redirect_to :root, notice: "Your account has been deleted."
    else

    end
  end

end
