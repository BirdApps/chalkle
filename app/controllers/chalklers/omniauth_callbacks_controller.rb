class Chalklers::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def meetup
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @chalkler = Chalkler.find_for_meetup_oauth(request.env["omniauth.auth"], current_chalkler)

    if @chalkler.persisted?
      sign_in_and_redirect @chalkler, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end
