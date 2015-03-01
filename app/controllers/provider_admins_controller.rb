class ProviderAdminsController < ApplicationController
  before_filter :load_admin, only: [:edit, :update]

  def new
      @provider_admin = ProviderAdmin.new provider: @provider
      authorize @provider_admin
      @page_title = "Admin"
  end

  def create
    @provider_admin = ProviderAdmin.new params[:provider_admin]
    @provider_admin.email.to_s.strip!
    authorize @provider_admin

    if @provider_admin.email.blank?
      add_flash :error, "You must supply an email"
    else
      exists = @provider_admin.provider.provider_admins.find(:first, conditions: ["lower(pseudo_chalkler_email) = ?", @provider_admin.email.strip.downcase]).present?
      exists = @provider_admin.provider.admin_chalklers.find(:first, conditions: ["lower(email) = ?", @provider_admin.email.strip.downcase]).present?

     if exists
        add_flash :error, "That person is already an admin on your provider"
      else
        result = @provider_admin.save
      end
    end

    if result
      redirect_to edit_provider_admin_path(@provider_admin.provider.url_name, @provider_admin.id), notice: 'Admin created successfully'
    else
      @provider_admin.errors.each do |attribute,error|
        flash[:notice] = attribute.to_s+" "+error
      end
      @page_title = "Teacher"
      render 'new'
    end
  end

  def edit
    authorize @provider_admin
  end

  def update
    authorize @provider_admin
    if @provider_admin.chalkler.blank?
      new_email = params[:provider_admin][:email]
      if new_email.blank?
        flash[:notice] = "You must supply an email"
      elsif @provider_admin.provider.admin_chalklers.find_by_email(new_email).present? || @provider_admin.provider.provider_admins.find_by_pseudo_chalkler_email(new_email).present?
        flash[:notice] = "That person is already an admin on your provider"
      else
        @provider_admin.email = new_email
        result = @provider_admin.save
      end

      if result
        redirect_to edit_provider_admin_path(@provider_admin.provider.url_name, @provider_admin.id), notice: 'Email updated successfully'
      else
        @provider_admin.errors.each do |attribute,error|
        flash[:notice] = attribute.to_s+" "+error
        end
        render 'edit'
      end
    end
  end


  private
    def load_admin
      @provider_admin = ProviderAdmin.find params[:id]
      return not_found if !@provider_admin
      @provider = @provider_admin.provider
      @page_title = "<a href='#{providers_admins_path(@provider_admin.provider.url_name)}'>Admins</a>".html_safe
    end
 
end