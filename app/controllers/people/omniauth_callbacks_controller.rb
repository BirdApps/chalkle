class People::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include OmniauthAuthenticationHelper

  def all
    identity = OmniauthIdentity.from_omniauth(request.env["omniauth.auth"])
    save_omniauth_authentication_to_session(identity)

    user = Chalkler.find_or_create_for_identity(identity)

    if user
      set_flash_message(:notice, :success, :kind => identity.provider) if is_navigational_format?
      sign_in_and_redirect(user)
    else
      flash[:error] = "Failed to log in with #{identity.provider}"
      redirect_to new_chalkler_registration_path
    end
  end

  alias_method :facebook, :all
  alias_method :meetup, :all

  def after_sign_in_path_for(resource)
    '/'
  end


end
