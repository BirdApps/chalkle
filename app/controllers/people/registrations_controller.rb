class People::RegistrationsController < Devise::RegistrationsController
  
  before_filter :set_up_header

  def new
    @new_chalkler = Chalkler.new unless @new_chalkler
  end

  def create
    build_resource

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
      flash_errors resource.errors
      clean_up_passwords resource
      respond_with resource
    end
  end


  private 

  def set_up_header
    @page_title =  "Learn"
    @meta_title = "Learn with "
    @show_header = false
  end

  def after_sign_up_path_for(resource)
    session[:previous_url] || discover_path
  end
end
