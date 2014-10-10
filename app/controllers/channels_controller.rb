class ChannelsController < ApplicationController
  before_filter :expire_cache!, only: [:create, :update, :destroy]
  after_filter :check_presence_of_courses, only: [:show, :series]
  before_filter :load_channel

  def index
    @channels = Channel.visible
  end

  def show
    not_found if @channel.new_record?
    @courses = @channel.courses.displayable.in_week(Week.containing(current_date)).by_date
    count = 0
    while @courses.blank? do
      break if count > 52
      count+=1
      @courses = @channel.courses.displayable.in_fortnight((Week.containing(current_date)+count)).by_date 
    end
  end

  def series 
    return not_found if @channel.new_record?
    @courses = @channel.courses.displayable.where url_name: params[:course_url_name]
    return not_found if @courses.empty?
    @courses
  end

  def new
    
  end

  def create
    
  end

  def edit
    authorize @channel
    @page_subtitle = 'Settings'
    not_found if !@channel
  end

  def update
    authorize @channel
    channel_params = params[:channel]
    @channel = Channel.find params[:channel_id]
    if params[:channel_agreeterms] == 'on'
      success = @channel.update_attributes channel_params
    end
    if success
      redirect_to channel_path @channel.url_name
    else
      render 'edit'
    end
  end



  def destroy
  end

  def contact
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
    @chalklers = @channel.chalklers
  end

  def teachers
    @teachers = ChannelTeacher.where channel_id:  @channel.id
    respond_to do |format|
      format.json { render json: @teachers.to_json(only: [:id, :name]) }
      format.html
    end
  end

  def url_available
    channels_with_url = Channel.where url_name:  params[:url_name]
    if (channels_with_url.empty? || channels_with_url.include?(@channel)) &&  !RouteRecognizer.new.initial_path_segments.contains(params[:url_name])
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