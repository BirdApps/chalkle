class ChannelsController < ApplicationController
  before_filter :expire_filter_cache!, only: [:create, :update, :destroy]
  after_filter :check_presence_of_courses, only: [:show, :series]
  before_filter :load_channel
  before_filter :authenticate_chalkler!, only: [:new, :create]

  def index
    @channels = Channel.visible
  end

  def show
    not_found if @channel.new_record?

    if current_user.super?
      @courses =  @channel.courses.in_future.start_at_between(current_date, current_date+1.year).by_date
    else
      @courses =  @channel.courses.in_future.displayable.start_at_between(current_date, current_date+1.year).by_date
      if current_user.authenticated?
        @courses += @channel.courses.taught_by_chalkler(current_chalkler).in_future.by_date+
                      @channel.courses.adminable_by(current_chalkler).in_future.by_date
        @courses = @courses.sort_by(&:start_at).uniq
      end
    end
  end

  def series 
    return not_found if !@channel || @channel.new_record?
    @courses = @channel.courses.displayable.in_future.by_date.where url_name: params[:course_url_name]
    return not_found if @courses.empty?
    @courses
  end

  def new
    @page_subtitle = "Create a new"
    @page_title = "Provider"
    @new_channel = Channel.new
  end

  def create
    @new_channel = Channel.new 
    @new_channel.name = params[:channel][:name]
    @new_channel.email = current_user.email
    @new_channel.channel_plan = ChannelPlan.default
    @new_channel.visible = true

    if @new_channel.save
        channel_admin = ChannelAdmin.create channel: @new_channel, chalkler: current_chalkler
        redirect_to channel_settings_path(@new_channel.url_name), notice: "Provider #{@new_channel.name} has been created"
      else
        @new_channel.errors.each do |attribute,error|
          add_response_notice attribute.to_s+" "+error
        end
        render 'new'
      end
  end

  def edit
    return not_found if !@channel
    authorize @channel
    @page_subtitle = 'Settings'
    not_found if !@channel
  end

  def update
    return not_found if !@channel
    authorize @channel
    channel_params = params[:channel]
    @channel = Channel.find params[:channel_id]
    
    if current_user.super?
      if @channel.update_attributes(channel_params,as: :admin)
        success = @channel.save
      end
    else
      if params[:channel_agreeterms] == 'on'
        if @channel.update_attributes channel_params
          success = @channel.save
        end
      end
    end
    
    if success
      redirect_to channel_settings_path @channel.url_name, notice: 'Settings saved'
    else
      flash[:notice] = 'Settings could not be saved'
      render 'edit'
    end
  end



  def destroy
  end

  def contact
    return not_found if !@channel
    @contact = ChannelContact.new channel: @channel
    if params[:submit] == 'send'
      @contact = ChannelContact.create from: params[:channel_contact][:from], subject: params[:channel_contact][:subject], message: params[:channel_contact][:message], channel: @channel, chalkler: current_chalkler
      if @contact.errors.blank?
        flash[:notice] = "Email has been sent"
      else
        flash[:notice] = "Email could not send, please check you've filled out all fields"
      end
    end
  end

  def followers
    return not_found if !@channel
    @chalklers = @channel.chalklers
  end

  def teachers
    return not_found if !@channel
    @teachers = ChannelTeacher.where channel_id:  @channel.id
    respond_to do |format|
      format.json { render json: @teachers.to_json(only: [:id, :name]) }
      format.html
    end
  end


  def admins
    return not_found if !@channel
    authorize @channel
    @admins = ChannelAdmin.where channel_id:  @channel.id
    respond_to do |format|
      format.json { render json: @admins.to_json(only: [:id, :name]) }
      format.html
    end
  end

  def url_available
    channels_with_url = Channel.where url_name:  params[:url_name]
    if (channels_with_url.empty? || channels_with_url.include?(@channel)) &&  !RouteRecognizer.new.initial_path_segments.include?(params[:url_name])
      render json: params[:url_name].parameterize 
    else
      render json: -1
    end
  end

  private 
  
  def load_channel
    redirect_to_subdomain
    if !@channel
      if channel_name 
        @channel = Channel.find_by_url_name(channel_name) || Channel.new(name: "All Providers")
      elsif params[:id].present?
        @channel = Channel.find(params[:id])
      elsif params[:channel_id].present?
        @channel = Channel.find(params[:channel_id])
      end
    end
    if !@channel
      @channel = Channel.new(name: "All Providers")
    end
    interacted_with @channel
  end

  def redirect_meetup_channels
    #if @channel.meetup_url.present?
    #  redirect_to @channel.meetup_url
      return false
    #end
  end

  def courses_for_time
    @courses_for_time ||= Querying::CoursesForTime.new(@channel.courses)
  end
end