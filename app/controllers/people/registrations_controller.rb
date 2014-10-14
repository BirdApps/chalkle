class People::RegistrationsController < Devise::RegistrationsController
  def create
    build_resource
    unless params[:chalkler][:password] == params[:chalkler][:password_confirmation]
      flash[:notice] = "Password confirmation must match password!"
      render 'new' and return
    end
    if resource.save
      resource.join_psuedo_identities!
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end
end