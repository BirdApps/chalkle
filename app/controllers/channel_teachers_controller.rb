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
    if current_user.chalkler?
      @courses += filter_courses(Course.taught_by_chalkler(current_user).in_future.by_date)+
                    filter_courses(Course.adminable_by(current_user).in_future.by_date)
      @courses = @courses.sort_by(&:start_at).uniq
    end

  end

  def edit
    authorize @channel_teacher
  end

  def update
    authorize @channel_teacher
    if @channel_teacher.chalkler.blank?
      existing_chalkler = Chalkler.exists params[:channel_teacher][:email]
      if existing_chalkler.present?
        if existing_chalkler.channels_teachable.include? @channel_teacher.channel
          add_flash :warning, "That email belongs to a chalkler already teaching on this channel"
          params[:channel_teacher][:email] = @channel_teacher.email
        else
          @channel_teacher.chalkler = existing_chalkler 
          add_flash :success, "Great! We found that chalkler and associated this teacher profile with them"
        end
        @channel_teacher.save
      end
    end
    @channel_teacher.update_attributes params[:channel_teacher]
    add_flash :success, 'Teacher has been updated'
    redirect_to edit_channel_teacher_path(@channel_teacher.id)
  end

  def new
      @channel_teacher =ChannelTeacher.new channel_id: @channel.id
      authorize @channel_teacher 
      @page_title = "Teacher"
  end

  def create
      @channel_teacher = ChannelTeacher.new params[:channel_teacher]
      @channel_teacher.email.to_s.strip!
      authorize @channel_teacher

      if @channel_teacher.email.blank?
        add_flash :error, "You must supply an email"
      else
        exists = @channel_teacher.channel.channel_teachers.find(:first, conditions: ["lower(pseudo_chalkler_email) = ?", @channel_teacher.email.strip.downcase]).present?
        exists = @channel_teacher.channel.teaching_chalklers.find(:first, conditions: ["lower(email) = ?", @channel_teacher.email.strip.downcase]).present? unless exists

        if exists
          add_flash :error, "That person is already a teacher on your channel"
        else
          @channel_teacher.name = @channel_teacher.name || @channel_teacher.email.split('@')[0]
          result = @channel_teacher.save
        end
      end

      if result
        redirect_to channel_channel_teacher_path(@channel_teacher.channel.url_name, @channel_teacher)
      else
        flash_errors @channel_teacher.errors
        @page_title = "Teacher"
        render 'new'
      end
  end

  private
    def load_teacher
      @channel_teacher = ChannelTeacher.find params[:id]
      return not_found if !@channel_teacher
    end
end