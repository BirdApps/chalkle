class CoursesController < ApplicationController
  before_filter :load_course, only: [:show, :tiny_url, :update, :edit, :confirm_cancel, :cancel, :bookings, :clone]
  before_filter :header_course, only: [:show, :update, :edit, :confirm_cancel, :cancel, :bookings, :clone]
  before_filter :check_course_visibility, only: [:show]
  before_filter :authenticate_chalkler!, only: [:new, :mine]
  before_filter :take_me_to, only: [:index]
  before_filter :header_teach, only: :teach
  before_filter :header_mine, only: :mine
  
  def index
   @header_partial = '/layouts/headers/discover'
  end

  def fetch
    if current_user.super?
      courses = Course.in_future.start_at_between(current_date, current_date+1.year).by_date
    else
      courses = Course.in_future.published.start_at_between(current_date, current_date+1.year).by_date
    end

    if params[:search].present?
      courses = courses.search params[:search].encode("UTF-8", "ISO-8859-1")
    end
    
    if params[:top].present? && params[:bottom].present? && params[:left].present? && params[:right].present?
      courses = courses.where("latitude < ? AND latitude > ? AND longitude < ? AND longitude > ?", params[:top].to_f, params[:bottom].to_f, params[:right].to_f, params[:left].to_f);
    end

    if params[:only_location].present?
      courses  = courses.map { |c| { id: c.id, lat: c.latitude, lng: c.longitude} }
    else
      courses = courses.limit(20).map do |c|
        {
          id: c.id, 
          name: c.name,
          action_call: c.call_to_action,
          url: provider_course_path(c.provider.url_name,c.url_name,c.id), 
          booking_url: new_course_booking_path(c.id),  
          name: c.name, 
          image: c.course_upload_image.url(:large), 
          cost: c.cost_formatted(true),
          color: c.provider.header_color, 
          provider: c.provider.name, 
          provider_image: c.provider.logo.url,
          provider_url: provider_path(c.provider.url_name), 
          teacher: (c.teacher ? c.teacher.name : 'No teacher assigned' ), 
          teacher_url: (c.teacher ? provider_provider_teacher_path(c.provider.url_name,c.teacher) : '#'), 
          status: c.status, 
          status_color: 'alert-'+c.status_color,
          type: c.course_type, 
          address: c.address,
          lat: c.latitude, 
          lng: c.longitude, 
          time: c.time_formatted
        }
      end
    end

    render json: courses
  end

  def show
    authorize @course 
    respond_to do |format|
      format.json { render json: { name: @course.name, url: @course.path, time: @course.time_formatted, cost: @course.cost_formatted(true) } }
      format.html { redirect_to @course.path unless request.path == @course.path and return }
    end
  end

  def mine
    @courses = current_user.super? ? mine_filter(Course.order(:start_at)).uniq : (mine_filter(current_user.courses_adminable)+mine_filter(current_user.courses_teaching)).sort_by(&:start_at).uniq
  end

  def teach
    @page_title =  "Teach"
    @meta_title = "Teach with "

    @show_header = false unless chalkler_signed_in?
    render 'teach'
  end

  def learn
    @page_title =  "Learn"
    @meta_title = "Learn with "
    @show_header = false unless chalkler_signed_in?
    @upcoming_courses = current_user.courses
    render 'learn'
  end

  def new
    @teaching = Teaching.new current_user
  end

  def create
    @teaching = Teaching.new current_user
    if params[:teaching_agreeterms] == 'on'
      new_course_ids =  @teaching.submit params[:teaching]
    end
    if new_course_ids && new_course_ids[0] != nil
      redirect_to course_path new_course_ids[0]
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

      redirect_to course_path @course.id
    else
      @course.errors.each do |attribute,error|
        add_response_notice attribute.to_s+" "+error
      end
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
    course = Course.find_by_id params[:id]
    return not_found if !course
    authorize course
    new_status = params[:course][:status]
    if new_status == 'publish_series'
      new_status = 'Published'
      course.repeat_course.courses.each do |series_course|
        series_course.publish! if series_course.status == 'Draft'
      end
    end
    course.status = new_status
    flash[:notice] = "Course not ready to publish. Please edit it to fix any issues" if !course.save
    redirect_to course_path(course)
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
    flash[:notice] = "You are now creating a copy of "+@course.name
    render 'new' 
  end

  private

    def load_course
      @course = Course.find_by_id(params[:id])
      return not_found unless @course
      authorize @course
      @provider = @course.provider
    end

    def header_course
      @header_partial = '/layouts/headers/provider'
      @page_title_logo = @course.provider.logo
      @page_title = "[#{@course.provider.name}](#{provider_path(@course.provider.url_name)})"
      @nav_links = []
      if @course.spaces_left?
          @nav_links << {
            img_name: "bolt",
            link: new_course_booking_path(@course.id),
            active: request.path.include?("new"),
            title: "Join"
          }
      end
      if policy(@course).read?
        @nav_links << {
            img_name: "bolt",
            link: course_bookings_path(@course),
            active: request.path.include?("bookings"),
            title: "Bookings"
          }
      end
      if policy(@course).edit?
        @nav_links << {
          img_name: "settings",
          link: edit_course_path(@course),
          active: request.path.include?("edit"),
          title: "Edit"
        }
      end
      if policy(@course).write?(true)
        @nav_links << {
          img_name: "people",
          link: clone_course_path(@course),
          active: false,
          title: "Copy"
        }
      end
    end

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

    def header_mine
      if current_user.providers_adminable.count == 1
        provider = current_user.providers_adminable.first
      end

      @page_title = "All Classes"
    end

    def header_teach
      @page_title = "Teach"
      @meta_title = "Teach with "
      @nav_links = [{
          img_name: "people",
          link: new_provider_path,
          active: false,
          title: "New Provider"
        },{
          img_name: "bolt",
          link: new_course_path,
          active: false,
          title: "New Class"
        }]

      if current_user.all_teaching.count > 0
        @nav_links << {
          img_name: "book",
          link: mine_courses_path,
          active: false,
          title: "My Classes"
        }
      end
    end

end