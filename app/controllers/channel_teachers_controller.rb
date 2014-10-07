class ChannelTeachersController < ApplicationController
  before_filter :load_teacher, only: [:show,:update,:edit]

  def index
    @teachers = ChannelTeacher.all
    respond_to do |format|
      format.json { render json: @teachers.to_json(only: [:id, :name]) }
      format.html { render @teachers }
    end
  end

  def show
    @courses = Course.where(teacher_id: @channel_teacher.id).in_future.displayable.by_date
  end

  def edit
    @page_subtitle = "editing"
    authorize @channel_teacher
  end

  def update
    @page_subtitle = "editing"
    authorize @channel_teacher
    if @channel_teacher.chalkler.blank?
      existing_chalkler = Chalkler.find_by_email params[:channel_teacher][:email]
      if existing_chalkler.present?
        if existing_chalkler.channels_teachable.include? @channel_teacher.channel
          add_response_notice "That email belongs to a chalkler already teaching on this channel"
          params[:channel_teacher][:email] = @channel_teacher.email
        else
          @channel_teacher.chalkler = existing_chalkler 
          add_response_notice "Great! We found that chalkler and associated this teacher profile with them"
        end
        @channel_teacher.save
      end
    end
    @channel_teacher.update_attributes params[:channel_teacher]
    render 'edit'
  end

  def new
      @channel_teacher =ChannelTeacher.new channel_id: @channel.id
      authorize @channel_teacher 
      @page_subtitle = "Create a New"
      @page_title = "Teacher"
  end

  def create
      @channel_teacher = ChannelTeacher.new params[:channel_teacher]      
      authorize @channel_teacher.channel

      if @channel_teacher.email.blank?
        add_response_notice "You must supply an email"
      elsif @channel_teacher.channel.teaching_chalklers.find_by_email(@channel_teacher.email).present? || @channel_teacher.channel.channel_teachers.find_by_pseudo_chalkler_email(@channel_teacher.email).present?
        add_response_notice "That person is already a teacher on your channel"
      else
        @channel_teacher.name = @channel_teacher.email.split('@')[0]
        @channel_teacher.can_make_classes = false
        result = @channel_teacher.save
      end

      if result
        redirect_to channel_channel_teacher_path(@channel_teacher.id)
      else
        @channel_teacher.errors.each do |attr,error|
          add_response_notice error
        end
        @page_subtitle = "Create a New"
        @page_title = "Teacher"
        render 'new'
      end
  end

  private
    def load_teacher
      @channel_teacher = ChannelTeacher.find params[:id]
    end
end