class Me::PreferencesController < Me::BaseController

  before_filter :load_chalkler, only: [:show,:update,:enter_email,:notifications,:update_notifications]
  before_filter :sidebar_administrate_chalkler, only: [:show,:update,:notifications,:update_notifications]
  before_filter :header_chalkler, only: [:show,:update,:enter_email,:notifications,:update_notifications]

  def sidebar_open
    if params[:sidebar_open].present?
      if params[:sidebar_open] == "false"
        current_chalkler.sidebar_open = false;
      else
        current_chalkler.sidebar_open = true;
      end
      current_chalkler.save
    end
    render json: current_chalkler.sidebar_open
  end

  def update
   	@chalkler_email_preferences = ChalklerPreferences.new(current_chalkler)

    if @chalkler_email_preferences.update_attributes(params[:chalkler_preferences])
      redirect_to me_preferences_path, notice: 'Your preferences have been saved.'
    else
      redirect_to me_root_path
    end
  end

  def show
    @chalkler_email_preferences = ChalklerPreferences.new(current_chalkler)
    render template: 'me/preferences/settings'
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
        flash_errors @chalkler.errors
      end
    end
  end

  def notifications
    @notification_preference = current_user.notification_preference || NotificationPreference.create(chalkler: current_user.chalkler)
    render template: 'me/preferences/notifications'
  end

  def update_notifications 
    @notification_preference = current_user.notification_preference || NotificationPreference.new
    @notification_preference.preferences = Hash[ params[:notification_preference].collect{|k,v| [k.to_sym, (v=="1" ? true : false)] }]
    @notification_preference.save
    redirect_to me_notification_preference_path, notice: "Your settings have been updated"
  end

  # def destroy
  #   @chalkler = current_chalkler
  #   @chalkler.destroy 
  #   redirect_to :root, notice: "Your account has been deleted."
  # end

  private
    def load_chalkler
      @chalkler = current_chalkler
    end

end
