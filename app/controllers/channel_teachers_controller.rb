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
    @courses = Course.where(teacher_id: @teacher.id).in_future.displayable.by_date
  end

  def edit
    @page_subtitle = "editing"
  end

  def update
    @page_subtitle = "editing"
  end

  def new
      authorize @channel
      @page_subtitle = "Create a New"
      @page_title = "Teacher"
      @channel_teacher = ChannelTeacher.new channel_id: @channel.id
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
        result = @channel_teacher.save
      end

      if result
        redirect_to channel_teacher_path(@channel_teacher.id)
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
      @teacher = ChannelTeacher.find params[:id]
    end
end