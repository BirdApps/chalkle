class CoursesController < ApplicationController
  before_filter :load_course, only: [:show, :tiny_url, :update, :edit, :confirm_cancel, :cancel, :bookings]
  before_filter :check_course_visibility, only: [:show]
  before_filter :authenticate_chalkler!, only: [:new]
  before_filter :check_clear_filters, only: [:index]
  before_filter :take_me_to, only: [:index]
  before_filter :expire_filter_cache!, only: [:update,:create,:confirm_cancel,:change_status]

  def index
    @courses = filter_courses(Course.displayable.start_at_between(current_date, current_date+1.year).by_date)
    
    if current_user.authenticated?
      @courses += filter_courses(Course.taught_by_chalkler(current_chalkler).in_future.by_date)+
                  filter_courses(Course.adminable_by(current_chalkler).in_future.by_date)
      @courses = @courses.sort_by(&:start_at).uniq
    end
  
  end

  def show
    return not_found if !@course
  end

  def teach
    render 'teach'
  end
  def learn
    render 'learn'
  end

  def tiny_url
    return not_found if !@course
    return redirect_to @course.path
  end

  def new
    @teaching = Teaching.new current_user
  end

  def create
    @teaching = Teaching.new current_user
    if params[:teaching_agreeterms] == 'on'
      new_course_ids =  @teaching.submit params[:teaching]
    end
    if new_course_ids
      redirect_to course_path new_course_ids[0]
    else
      render 'new'
    end
  end

  def edit
    @page_subtitle = 'Editing'
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
      redirect_to course_path @course.id
    else
      render 'new'
    end
  end

  def cancel
    authorize @course
    return render 'cancel'
  end

  def confirm_cancel
    authorize @course
    @course.cancel!(params[:course][:cancelled_reason])
    return redirect_to @course.path
  end

  def destroy

  end
  
  def change_status
    course = Course.find params[:id]
    authorize course
    new_status = params[:course][:status]
    if new_status == 'publish_series'
      new_status = 'Published'
      course.repeat_course.courses.each do |series_course|
        series_course.publish! if series_course.status == 'Unreviewed'
      end
    end
    course.status = new_status
    flash[:notice] = "Course not ready to publish. Please edit it to fix any issues" if !course.save
    redirect_to course_path(course)
  end

  def bookings
    authorize @course
  end

  def calculate_cost
    @course = Course.new params[:course]
    render json: @course.as_json(methods: [:channel_fee, :chalkle_fee, :processing_fee, :teacher_max_income, :teacher_min_income, :channel_min_income, :channel_max_income, :teacher_pay_variable, :teacher_pay_flat])
  end

  private

    def take_me_to
      if params[:search].present?
        try_id = params[:search] 
        course = Course.find_by_id try_id
        return redirect_to course.path if course.present?
      end
    end

    def filter_courses(courses)
      if @region.id.present? && @category.id.present? && @channel.id.present?
        courses = courses.in_region(@region).in_category(@category).in_channel(@channel)
      elsif @region.id.present? && @category.id.present? && @channel.id.nil?    
        courses = courses.in_region(@region).in_category(@category) 
      elsif @region.id.present? && @category.id.nil? && @channel.id.present?
        courses = courses.in_region(@region).in_channel(@channel)
      elsif @region.id.nil? && @category.id.present? && @channel.id.present?  
        courses = courses.in_category(@category).in_channel(@channel)
      elsif @region.id.nil? && @category.id.nil? && @channel.id.present?  
        courses = courses.in_channel(@channel)
      elsif @region.id.nil? && @category.id.present? && @channel.id.nil? 
        courses = courses.in_category(@category)   
      elsif @region.id.present? && @category.id.nil? && @channel.id.nil?
        courses = courses.in_region(@region)
      end
      if params[:search].present?
        courses = Course.search params[:search], courses
      end
      courses
    end

    def load_course
      @course = Course.find_by_id(params[:id]).try :decorate
      authorize @course
      ActiveRecord::RecordNotFound if @course.nil?
    end  

    def load_geography_override
      load_country
      load_region
    end

    def load_region
      if region_name
        @region = Region.find_by_url_name region_name.downcase
      end
      if @region.nil?
        @region = Region.new name: "New Zealand", courses: Course.upcoming
      end
    end

    def load_category
      if category_name
        @category = Category.find_by_url_name category_name.downcase
      end
      if @category.nil?
        @category = Category.new name: 'All Topics'
      end
    end

    def load_channel
      if !@channel
        if channel_name 
          @channel = Channel.find_by_url_name(channel_name) || Channel.new(name: "All Providers")
        else
          @channel = Channel.new(name: "All Providers")
        end
      end
    end

    def check_course_visibility
      unless !@course || policy(@course).edit?
        unless @course.published?
          flash[:notice] = "This class is no longer available."
          redirect_to :root
          return false
        end
      end
    end

    def redirect_meetup_courses
      if @course.meetup_url.present?
        redirect_to @course.meetup_url
        return false
      end
    end

    def courses_for_time
      @courses_for_time ||= Querying::CoursesForTime.new(courses_base_scope)
    end

    def get_current_week(start_date = Date.current)
      if params[:day]
        Week.containing(Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i))
      else
        Week.containing(start_date)
      end
    end

    def decorate(courses)
      CourseDecorator.decorate_collection(courses)
    end

end