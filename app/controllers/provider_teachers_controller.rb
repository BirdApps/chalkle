class ProviderTeachersController < ApplicationController
  before_filter :load_teacher, only: [:show,:update,:edit]
  before_filter :header_teacher, only: [:show,:update,:edit]

  def index
    @teachers = ProviderTeacher.all
    respond_to do |format|
      format.json { render json: @teachers.to_json(only: [:id, :name]) }
      format.html { render @teachers }
    end
  end

  def show
    @courses = Course.where(teacher_id: @provider_teacher.id).in_future.displayable.by_date
  end

  def edit
    @page_subtitle = "editing"
    authorize @provider_teacher
  end

  def update
    @page_subtitle = "editing"
    authorize @provider_teacher
    if @provider_teacher.chalkler.blank?
      existing_chalkler = Chalkler.exists params[:provider_teacher][:email]
      if existing_chalkler.present?
        if existing_chalkler.providers_teachable.include? @provider_teacher.provider
          add_response_notice "That email belongs to a chalkler already teaching on this provider"
          params[:provider_teacher][:email] = @provider_teacher.email
        else
          @provider_teacher.chalkler = existing_chalkler 
          add_response_notice "Great! We found that chalkler and associated this teacher profile with them"
        end
        @provider_teacher.save
      end
    end
    @provider_teacher.update_attributes params[:provider_teacher]
    redirect_to edit_provider_teacher_path(@provider_teacher.id), notice: 'Teacher has been updated'
  end

  def new
      @provider_teacher =ProviderTeacher.new provider_id: @provider.id
      authorize @provider_teacher 
      @page_subtitle = "Create a New"
      @page_title = "Teacher"
  end

  def create
      @provider_teacher = ProviderTeacher.new params[:provider_teacher]
      @provider_teacher.email.to_s.strip!
      authorize @provider_teacher

      if @provider_teacher.email.blank?
        add_response_notice "You must supply an email"
      else
        exists = @provider_teacher.provider.provider_teachers.find(:first, conditions: ["lower(pseudo_chalkler_email) = ?", @provider_teacher.email.strip.downcase]).present?
        exists = @provider_teacher.provider.teaching_chalklers.find(:first, conditions: ["lower(email) = ?", @provider_teacher.email.strip.downcase]).present? unless exists

        if exists
          add_response_notice "That person is already a teacher on your provider"
        else
          @provider_teacher.name = @provider_teacher.name || @provider_teacher.email.split('@')[0]
          result = @provider_teacher.save
        end
      end

      if result
        redirect_to provider_provider_teacher_path(@provider_teacher.provider.url_name, @provider_teacher)
      else
        @provider_teacher.errors.each do |attribute,error|
          add_response_notice attribute.to_s+" "+error
        end
        @page_subtitle = "Create a New"
        @page_title = "Teacher"
        render 'new'
      end
  end

  private
    def load_teacher
      @provider_teacher = ProviderTeacher.find params[:id]
      return not_found if !@provider_teacher
    end

    def header_teacher
      @page_title_logo = @provider_teacher.provider.logo
      @page_title = @provider_teacher.name
      @page_subtitle = "<a href='#{provider_path(@provider_teacher.provider.url_name)}'>#{@provider_teacher.provider.name}</a>"
      @nav_links = [
        {
          img_name: "bolt",
          link: provider_provider_teacher_path(@provider_teacher.provider.url_name,@provider_teacher.id),
          active: request.path.include?("show"),
          title: "Classes"
        }
      ]

      if policy(@provider_teacher).edit?
        @nav_links <<  {
          img_name: "settings",
          link: edit_provider_teacher_path(@provider_teacher),
          active: request.path.include?("edit"),
          title: "Edit"
        }
      end

      if current_user.super? && @provider_teacher.chalkler_id.present?
        @nav_links <<  {
          img_name: "people",
          link: become_sudo_chalkler_path(@provider_teacher.chalkler_id),
          active: false,
          title: "Become"
        }
      end
    end
end