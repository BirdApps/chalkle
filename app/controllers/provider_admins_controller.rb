class ProviderAdminsController < ApplicationController
  before_filter :load_admin, only: [:edit, :update]
  before_filter :header_provider
  before_filter :sidebar_administrate_provider

  def index
    authorize @provider, :admins_index?
    @admins = ProviderAdmin.where provider_id:  @provider.id
    respond_to do |format|
      format.html
      format.json { render json: @admins.to_json(only: [:id, :name]) }
    end
  end

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
      flash_errors @provider_admin.errors
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
        add_flash :error, "You must supply an email"
      elsif @provider_admin.provider.admin_chalklers.find_by_email(new_email).present? || @provider_admin.provider.provider_admins.find_by_pseudo_chalkler_email(new_email).present?
        add_flash :error, "That person is already an admin on your provider"
      else
        @provider_admin.email = new_email
        result = @provider_admin.save
      end

      if result
        redirect_to edit_provider_admin_path(@provider_admin.provider, @provider_admin), notice: 'Email updated successfully'
      else
        flash_errors @provider_admin.errors
        render 'edit'
      end
    end
  end


  private
    def load_admin
      @provider_admin = ProviderAdmin.find params[:id]
      return not_found if !@provider_admin
      @provider = @provider_admin.provider
      @page_title = "<a href='#{provider_admins_path(@provider_admin.provider)}'>Admins</a>".html_safe
    end
 
end