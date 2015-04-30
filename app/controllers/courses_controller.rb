class CoursesController < ApplicationController
  before_filter :load_course, :sidebar_administrate_course, :header_provider, only: [:show, :tiny_url, :update, :edit, :confirm_cancel, :cancel, :bookings, :clone]
  before_filter :check_course_visibility, only: [:show]
  before_filter :authenticate_chalkler!, only: [:new, :mine]
  before_filter :take_me_to, only: [:index]
  before_filter :header_mine, only: :mine
  
  def index
  end

  def fetch
    if @provider
      @show_past_classes = true
      if policy(@provider).read?
        @courses = @provider.courses
      else
        @courses = @provider.courses.advertisable
      end
      if params['id'] 
        @provider_teacher = ProviderTeacher.where(id: params['id'].to_i).first
        @courses = @courses.taught_by(@provider_teacher)
      end
    else
      if current_user.super?
        @courses = Course.scoped
      else
        @courses = Course.advertisable
      end
    end

    if params[:past] == 'true'
      @courses = @courses.in_past.by_date.reverse
    else
      @courses = @courses.in_future.by_date
    end

    if params[:search].present?
      @courses = @courses.search params[:search].encode("UTF-8", "ISO-8859-1")
    end
    
    if params[:top].present? && params[:bottom].present? && params[:left].present? && params[:right].present?
      @courses = @courses.located_within_coordinates(
        { lat: params[:top].to_f,    long: params[:left].to_f   }, 
        { lat: params[:bottom].to_f, long: params[:right].to_f  }
      )
    end

    if params[:only_location].present?
      @courses  = @courses.map { |c| { id: c.id, lat: c.latitude, lng: c.longitude} }
      render json: @courses and return
    elsif @courses.empty? && request.path == classes_fetch_path
      #fall back to showing providers if no courses found
      
      if params[:search].present?
        providers_search = Provider.search params[:search].encode("UTF-8", "ISO-8859-1"), nil, true
      end

      if params[:top].present? && params[:bottom].present? && params[:left].present? && params[:right].present?
        providers_in_coords = Provider.has_active_course_within_coordinates(
          { lat: params[:top].to_f,    long: params[:left].to_f   }, 
          { lat: params[:bottom].to_f, long: params[:right].to_f  }
        )
      end


      @providers = if providers_in_coords.present? && providers_search.present?
        @fall_back_text = "Here's some providers who offer similar classes nearby"
        (providers_in_coords & providers_search).uniq
      elsif providers_in_coords.present?
        @fall_back_text = "Here's some providers offering exciting classes nearby"
        providers_in_coords.to_a.uniq
      elsif providers_search.present?
        @fall_back_text = "Here's some providers who offer similar classes"
        providers_search.to_a.uniq
      else
        @fall_back_text = "Check out some of the great class providers on Chalkle"
        Provider.has_displayable_classes.to_a.uniq
      end

    end
    
    render '_paginate_courses', layout: false
  end

  def series
    load_provider
    header_provider
    sidebar_administrate_provider
    not_found and return unless @provider.present?
    @courses_in_future = @provider.courses.where( url_name: course_name ).in_future.by_date.reverse
    @courses_in_past = @provider.courses.where( url_name: course_name ).in_past.by_date
    not_found and return unless @courses_in_future.present? || @courses_in_past.present?
  end

  def show
    redirect_to @course.path and return unless request.path == @course.path
    respond_to do |format|
      format.html
      format.json { render json: { 
        name: @course.name, url: @course.path, time: @course.time_formatted, cost: @course.cost_formatted(true) } and return
      }
    end
  end

  def mine
    @courses = current_user.super? ? mine_filter(Course.order(:start_at)).uniq : (mine_filter(current_user.courses_adminable)+mine_filter(current_user.courses_teaching)).sort_by(&:start_at).uniq
  end

  def choose_provider
    if current_user.providers.count == 1
      redirect_to new_provider_class_path(current_user.providers.first) and return
    end
  end

  def new
    @course = Course.new({name: "", provider: @provider})
    authorize @course
    @teaching = Teaching.new current_user, @course
    header_provider
    sidebar_administrate_provider
  end

  def create
    @teaching = Teaching.new current_user
    if params[:teaching_agreeterms] == 'on'
      new_course_ids = @teaching.submit params[:teaching]
    end
    if new_course_ids && new_course_ids[0] != nil
      redirect_to provider_course_path Course.find(new_course_ids[0]).path_params
    else
      render 'new'
    end
  end

  def edit
    authorize @course
    @teaching = Teaching.new current_user
    @teaching.course_to_teaching @course
  end

  def update
    authorize @course
    @teaching = Teaching.new current_user
    if params[:teaching_agreeterms] == 'on'
      success = @teaching.update @course, params[:teaching]
    end

    if success
      #recalculate booking fees in case they changed the provider/teacher money split
      @course.bookings.each do |booking|
        booking.apply_fees!
      end

      redirect_to provider_course_path @course.id
    else
      flash_errors @course.errors
      render 'new'
    end
  end

  def cancel
    authorize @course
    return render 'cancel'
  end

  def confirm_cancel
    authorize @course
    if @course.cancel!(params[:course][:cancelled_reason])
      Notify.for(@course).from(current_user).cancelled
    end
    return redirect_to @course.path
  end

  def destroy

  end
  
  def change_status
    course = Course.find_by_id params[:course_id]
    return not_found if !course
    authorize course
    case params[:status]
    when 'Published'
      course.status = params[:status]
      repeat_courses = course.repeat_course.try(:courses)
      if repeat_courses
        repeat_courses.each do |series_course|
          series_course.publish! if series_course.status == 'Preview'
        end
      end
    when 'Preview'
      course.status = params[:status]
    end
    flash_errors @course.errors if !course.save
    redirect_to provider_course_path(course)
  end

  def bookings
    @bookings = @course.bookings.visible
  end

  def calculate_cost
    @course = Course.new params[:course]
    render json: @course.as_json(methods: [:provider_fee, :chalkle_fee, :processing_fee, :teacher_max_income, :teacher_min_income, :provider_min_income, :provider_max_income, :teacher_pay_variable, :teacher_pay_flat])
  end


  def clone
    authorize @course
    @teaching = Teaching.new current_user
    @teaching.course_to_teaching @course
    @teaching.cloning_id = @teaching.editing_id
    @teaching.editing_id = nil
    add_flash :info, "You are now editing a preview copy of #{@course.name}"
    render 'new'
  end

  private

    def take_me_to
      if params[:search].present?
        try_id = params[:search] 
        course = Course.find_by_id try_id if try_id =~ /^\d+$/
        return redirect_to course.path if course.present? && policy(course).read?
      end
    end

    def filter_courses(courses)
      if @provider.id.present?
        courses = courses.in_provider(@provider)
      end
      if params[:search].present?
        courses = Course.search params[:search], courses
      end
      courses
    end

    def mine_filter(courses)
      if params[:start].present? || params[:end].present?
        range_start = params[:start].to_datetime.in_time_zone(current_user.timezone) if params[:start].present?
        range_end = params[:end].to_datetime.in_time_zone(current_user.timezone) if params[:end].present?
        range_start = range_start || DateTime.new(2000,1,1)
        range_end = range_end || DateTime.new(2100,1,1)
        courses = courses.start_at_between(range_start, range_end)
      end

      if params[:search].present?
        courses = Course.search params[:search], courses
      end

      courses
    end

end