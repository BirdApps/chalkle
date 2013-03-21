class Chalklers::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def meetup
    @chalkler = Chalkler.find_for_meetup_oauth(request.env["omniauth.auth"], current_chalkler)

    if @chalkler.persisted?
      sign_in_and_redirect @chalkler, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Meetup") if is_navigational_format?
    else
      session["devise.meetup_data"] = request.env["omniauth.auth"]
      redirect_to new_chalkler_registration_url
    end
  end

  def after_sign_in_path_for(resource)
    if resource.sign_in_count == 1 and resource.email.blank?
      chalklers_update_email_path
    else
      super
    end
  end
end
