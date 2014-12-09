class Me::PreferencesController < Me::BaseController

  before_filter :check_user_data, only: :destroy

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
    unless params[:chalkler].blank?
      @chalkler.email = params[:chalkler][:email]
      if @chalkler.save
        if session[:original_path].present?
          redirect_to session[:original_path], notice: "Thanks for completeing your profile!"
        else
          redirect_to :root, notice: 'Welcome to chalkle! Sign in successful.'
        end
      else
        @chalkler.errors.each do |attribute,error|
          add_response_notice attribute.to_s+" "+error
        end
      end
    end
  end

  def notifications
    @preferences_notifications = current_user.notification_preference
    unless params[:chalkler_id].blank?
      
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
