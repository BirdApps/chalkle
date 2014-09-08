class ChannelsController < ApplicationController
  before_filter :expire_filter_cache, only: [:create, :update, :destroy]
  after_filter :check_presence_of_courses, only: [:show, :series]

  def index
    @channels = Channel.visible
  end

  def show
    not_found if !@channel
    @courses = @channel.courses.displayable.in_week(Week.containing(current_date)).by_date
  end

  def series 
    not_found if !@channel
    @courses = @channel.courses.displayable.where url_name: params[:course_url_name]
  end

  def new
    
  end

  def create
    
  end


  def edit
    
  end

  def update
    
  end


  def destroy
    
  end

  def contact
  end

  def teachers
    @teachers = ChannelTeacher.where(channel_id: params[:channel_id]).compact
    respond_to do |format|
      format.json { render json: @teachers.to_json(only: [:id, :name]) }
      format.html { render @teachers }
    end
  end

  private 

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