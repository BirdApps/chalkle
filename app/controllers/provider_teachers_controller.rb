class ProviderTeachersController < ApplicationController
  before_filter :header_provider
  before_filter :load_teacher, only: [:show,:update,:edit]

  def index
    return not_found unless @provider
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
        Notify.for(@provider_teacher).added_to_provider(current_user.chalkler)
        redirect_to provider_teacher_path(@provider_teacher.path_params)
      else
        flash_errors @provider_teacher.errors
        @page_title = "Teacher"
        render 'new'
      end
  end

  def new_from_csv
    redirect_to :new_provider_teacher, flash: { error: "CSV upload failed, no file attached" } and return unless params[:provider_teacher_csv]
    @provider_teachers = []
    csv =  CSV.read params[:provider_teacher_csv].path

    csv.each do |row|
      name = row[0]
      email = row[1]
      chalkler = Chalkler.find_by_email email

      @provider_teachers << if chalkler
        ProviderTeacher.new chalkler: chalkler, name: name
      else
        ProviderTeacher.new pseudo_chalkler_email: email, name: name 
      end
    end
  end

  def bulk_create
    errors = []
    warnings = []
    @provider_teachers = []
    params[:provider_teachers].each do |teacher|

      chalkler = Chalkler.find_by_email teacher[:email]

      existing_teacher = chalkler ? @provider.provider_teachers.find_by_chalkler_id(chalkler.id) : @provider.provider_teachers.find_by_pseudo_chalkler_email(teacher[:email])

      unless existing_teacher

         new_teacher = if chalkler 
          ProviderTeacher.create chalkler: chalkler, name: teacher[:name], provider: @provider,can_make_classes: teacher[:can_make_classes]
        else
          ProviderTeacher.create pseudo_chalkler_email: teacher[:email], name: teacher[:name], provider: @provider, can_make_classes: teacher[:can_make_classes]
        end
        
        @provider_teachers << new_teacher

        unless new_teacher.persisted?
          errors << "Problem occured creating teacher with email #{teacher[:email]}" 
        else
          Notify.for(@provider_teacher).added_to_provider(current_user.chalkler)
        end
        
      else
        warnings << "Teacher with email #{teacher[:email]} already exists" unless new_teacher
      end
    
    end

    render 'new_from_csv', flash: { errors: errors } and return if errors.present?

    redirect_to provider_teachers_path, flash: { success: "#{@provider_teachers.count} teachers created", errors: warnings }

  end

  private
    def load_teacher
      @provider_teacher = ProviderTeacher.find params[:id]
      return not_found if !@provider_teacher
    end

end