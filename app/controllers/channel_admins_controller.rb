class ChannelAdminsController < ApplicationController
  before_filter :load_admin, only: [:edit, :update]

  def new
      @channel_admin = ChannelAdmin.new channel: @channel
      authorize @channel_admin
      @page_subtitle = "Create a New"
      @page_title = "Admin"
  end

  def create
    @channel_admin = ChannelAdmin.new params[:channel_admin]
    @channel_admin.email.to_s.strip!
    authorize @channel_admin

    if @channel_admin.email.blank?
      add_response_notice "You must supply an email"
    else
      exists = @channel_admin.channel.channel_admins.find(:first, conditions: ["lower(pseudo_chalkler_email) = ?", @channel_admin.email.strip.downcase]).present?
      exists = @channel_admin.channel.admin_chalklers.find(:first, conditions: ["lower(email) = ?", @channel_admin.email.strip.downcase]).present?

     if exists
        add_response_notice "That person is already an admin on your channel"
      else
        result = @channel_admin.save
      end
    end

    if result
      redirect_to edit_channel_admin_path(@channel_admin.channel.url_name, @channel_admin.id), notice: 'Admin created successfully'
    else
      @channel_admin.errors.each do |attribute,error|
        add_response_notice attribute.to_s+" "+error
      end
      @page_subtitle = "Create a New"
      @page_title = "Teacher"
      render 'new'
    end
  end

  def edit
    authorize @channel_admin
  end

  def update
    authorize @channel_admin
    if @channel_admin.chalkler.blank?
      new_email = params[:channel_admin][:email]
      if new_email.blank?
        add_response_notice "You must supply an email"
      elsif @channel_admin.channel.admin_chalklers.find_by_email(new_email).present? || @channel_admin.channel.channel_admins.find_by_pseudo_chalkler_email(new_email).present?
        add_response_notice "That person is already an admin on your channel"
      else
        @channel_admin.email = new_email
        result = @channel_admin.save
      end

      if result
        redirect_to edit_channel_admin_path(@channel_admin.channel.url_name, @channel_admin.id), notice: 'Email updated successfully'
      else
        @channel_admin.errors.each do |attribute,error|
        add_response_notice attribute.to_s+" "+error
        end
        render 'edit'
      end
    end
  end


  private
    def load_admin
      @channel_admin = ChannelAdmin.find params[:id]
      return not_found if !@channel_admin
      @channel = @channel_admin.channel
      @page_subtitle = "<a href='#{channel_path(@channel_admin.channel.url_name)}'>#{@channel_admin.channel.name}</a>".html_safe
      @page_title = "<a href='#{channels_admins_path(@channel_admin.channel.url_name)}'>Admins</a>".html_safe
    end
 
end