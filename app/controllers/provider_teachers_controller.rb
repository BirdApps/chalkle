class ProviderTeachersController < ApplicationController
  before_filter :load_provider, :header_provider, :sidebar_administrate_provider
  before_filter :load_teacher, only: [:show,:update,:edit]

  def index
    
    @teachers = @provider.provider_teachers.sort_by{ |p| p.next_class.present? ? p.next_class.start_at : DateTime.current.advance(years: 100) }

    respond_to do |format|
      format.html
      format.json { render json: @teachers.to_json(only: [:id, :name]) }
    end
  end
  
  def show
    @courses = Course.where(teacher_id: @provider_teacher.id).in_future.displayable.by_date
  end

  def edit
    authorize @provider_teacher
  end

  def update
    authorize @provider_teacher
    if @provider_teacher.chalkler.blank?
      existing_chalkler = Chalkler.exists params[:provider_teacher][:email]
      if existing_chalkler.present?
        if existing_chalkler.providers_teachable.include? @provider_teacher.provider
          add_flash :error, "That email belongs to a chalkler already teaching on this provider"
          params[:provider_teacher][:email] = @provider_teacher.email
        else
          @provider_teacher.chalkler = existing_chalkler 
          add_flash :success, "Great! We found that chalkler and associated this teacher profile with them"
        end
        @provider_teacher.save
      end
    end
    @provider_teacher.update_attributes params[:provider_teacher]
    redirect_to provider_teacher_path(@provider_teacher.path_params), notice: 'Teacher has been updated'
  end

  def new
      @provider_teacher =ProviderTeacher.new provider_id: @provider.id
      authorize @provider_teacher 
      @page_title = "Teacher"
  end

  def create
      @provider_teacher = ProviderTeacher.new params[:provider_teacher]
      @provider_teacher.email.to_s.strip!
      authorize @provider_teacher

      if @provider_teacher.email.blank?
        add_flash :error, "You must supply an email"
      else
        exists = @provider_teacher.provider.provider_teachers.find(:first, conditions: ["lower(pseudo_chalkler_email) = ?", @provider_teacher.email.strip.downcase]).present?
        exists = @provider_teacher.provider.teaching_chalklers.find(:first, conditions: ["lower(email) = ?", @provider_teacher.email.strip.downcase]).present? unless exists

        if exists
          add_flash :error,"That person is already a teacher on your provider"
        else
          @provider_teacher.name = @provider_teacher.name || @provider_teacher.email.split('@')[0]
          result = @provider_teacher.save
        end
      end

      if result
        redirect_to provider_teacher_path(@provider_teacher.path_params)
      else
        flash_errors @provider_teacher.errors
        @page_title = "Teacher"
        render 'new'
      end
  end

  private
    def load_teacher
      @provider_teacher = ProviderTeacher.find params[:id]
      return not_found if !@provider_teacher
    end

end