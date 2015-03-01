class ProvidersController < ApplicationController
  after_filter  :check_presence_of_courses, only: [:show, :series]
  before_filter :load_provider, only: [:show, :bookings, :series, :edit, :update, :contact, :followers, :teachers, :admins]
  before_filter :header_provider, only: [:show, :bookings, :series, :edit, :update, :contact, :followers, :teachers, :admins]
  before_filter :authenticate_chalkler!, only: [:new, :create]

  def index
    @providers = Provider.visible
  end

  def show
    if current_user.super?
      @courses =  @provider.courses.in_future.start_at_between(current_date, current_date+1.year).by_date
    else
      @courses =  @provider.courses.in_future.displayable.start_at_between(current_date, current_date+1.year).by_date
      if current_user.authenticated?
        @courses += @provider.courses.taught_by_chalkler(current_chalkler).in_future.by_date+
                      @provider.courses.adminable_by(current_chalkler).in_future.by_date
        @courses = @courses.sort_by(&:start_at).uniq
      end
    end
  end

  def series 
    @courses = @provider.courses.displayable.in_future.by_date.where url_name: params[:course_url_name]
    return not_found if @courses.empty?
    @courses
  end

  def new
    @page_title = "Provider"
    @new_provider = Provider.new
  end

  def create
    @new_provider = Provider.new 
    @new_provider.name = params[:provider][:name]
    @new_provider.email = current_user.email
    @new_provider.provider_plan = ProviderPlan.default
    @new_provider.visible = true

    if @new_provider.save
        provider_admin = ProviderAdmin.create provider: @new_provider, chalkler: current_chalkler
        redirect_to provider_settings_path(@new_provider.url_name), notice: "Provider #{@new_provider.name} has been created"
      else
        @new_provider.errors.each do |attribute,error|
          flash[:notice] = attribute.to_s+" "+error
        end
        render 'new'
      end
  end

  def edit
    authorize @provider
  end

  def update
    authorize @provider
    provider_params = params[:provider]
    @provider = Provider.find params[:provider_id]
    
    if current_user.super?
      if @provider.update_attributes(provider_params,as: :admin)
        success = @provider.save
      end
    else
      if params[:provider_agreeterms] == 'on'
        if @provider.update_attributes provider_params
          success = @provider.save
        end
      end
    end
    
    if success
      redirect_to provider_settings_path @provider.url_name, notice: 'Settings saved'
    else
      flash_errors @provider.errors
      render 'edit'
    end
  end



  def destroy
  end

  def contact
    @contact = ProviderContact.new provider: @provider
    if params[:submit] == 'send'
      @contact = ProviderContact.create from: params[:provider_contact][:from], subject: params[:provider_contact][:subject], message: params[:provider_contact][:message], provider: @provider, chalkler: current_chalkler
      if @contact.errors.blank?
        flash[:notice] = "Email has been sent"
      else
        flash[:notice] = "Email could not send, please check you've filled out all fields"
      end
    end
  end

  def followers
    @chalklers = @provider.chalklers
  end

  def follower
    @chalkler = Chalkler.find params[:chalkler_id]
    return not_found if !@chalkler
    #TODO: see interactions with follower
  end

  def bookings
    authorize @provider
    @bookings = @provider.bookings.order(:course_id).reverse
  end

  def teachers
    @teachers = ProviderTeacher.where provider_id:  @provider.id
    respond_to do |format|
      format.json { render json: @teachers.to_json(only: [:id, :name]) }
      format.html
    end
  end


  def admins
    authorize @provider
    @admins = ProviderAdmin.where provider_id:  @provider.id
    respond_to do |format|
      format.json { render json: @admins.to_json(only: [:id, :name]) }
      format.html
    end
  end

  def url_available
    providers_with_url = Provider.where url_name:  params[:url_name]
    if (providers_with_url.empty? || providers_with_url.include?(@provider)) &&  !RouteRecognizer.new.initial_path_segments.include?(params[:url_name])
      render json: params[:url_name].parameterize 
    else
      render json: -1
    end
  end

  private 
  

  def check_presence_of_courses
    unless @courses.present?
      add_response_notice(notice)
    end
  end

  def load_provider
    redirect_to_subdomain
    if params[:id].present?
      @provider = Provider.find(params[:id])
    elsif params[:provider_id].present?
      @provider = Provider.find(params[:provider_id])
    elsif provider_name 
      @provider = Provider.find_by_url_name(provider_name) 
    end
    not_found and return if @provider.blank?
  end

  def courses_for_time
    @courses_for_time ||= Querying::CoursesForTime.new(@provider.courses)
  end
end