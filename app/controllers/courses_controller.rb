class CoursesController < ApplicationController
  before_filter :load_course, only: [:show, :tiny_url, :update, :edit, :confirm_cancel, :cancel, :bookings, :clone]
  before_filter :check_course_visibility, only: [:show]
  before_filter :authenticate_chalkler!, only: [:new, :mine]
  before_filter :check_clear_filters, only: [:index]
  before_filter :take_me_to, only: [:index]
  before_filter :expire_filter_cache!, only: [:update,:create,:confirm_cancel,:change_status]

  def index
    if current_user.super?
      @courses = filter_courses(Course.in_future.start_at_between(current_date, current_date+1.year).by_date)
    else
      @courses = filter_courses(Course.in_future.displayable.start_at_between(current_date, current_date+1.year).by_date)
      if current_user.chalkler?
        @courses += filter_courses(Course.taught_by_chalkler(current_user).in_future.by_date)+
                    filter_courses(Course.adminable_by(current_user).in_future.by_date)
        @courses = @courses.sort_by(&:start_at).uniq
      end
    end
  end

  def show
    authorize @course
    redirect_to @course.path unless request.path == @course.path and return
  end

  def mine
    if current_user.channels_adminable.count == 1
      channel = current_user.channels_adminable.first
      @page_subtitle = "<a href='#{channel_path(channel.url_name)}'>#{channel.name}</a>".html_safe
    else
        @page_subtitle = "From all your providers"
    end

    @page_title = "All Classes"
    @courses = current_user.super? ? mine_filter(Course.order(:start_at)) : (mine_filter(current_user.courses_adminable)+mine_filter(current_user.courses_teaching)).sort_by(&:start_at)
  end

  

  def teach
    @page_subtitle = "Use chalkle to"
    @page_title = "Teach"
    @meta_title = "Teach with "

    @page_context_links = [
      {
        img_name: "people",
        link: new_channel_path,
        active: false,
        title: "New Provider"
      },
      {
        img_name: "bolt",
        link: new_course_path,
        active: false,
        title: "New Class"
      }
    ]

    if current_user.all_teaching.count > 0
      @page_context_links << {
        img_name: "book",
        link: mine_courses_path,
        active: false,
        title: "My Classes"
      }
    end
    render 'teach'
  end

  def learn
    @page_subtitle = "Use chalkle to"
    @page_title =  "Learn"
    @meta_title = "Learn with "
    @upcoming_courses = current_user.courses
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

      #recalculate booking fees in case they changed the provider/teacher money split
      @course.bookings.each do |booking|
        booking.apply_fees
        booking.save
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
    @course.cancel!(params[:course][:cancelled_reason])
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
        series_course.publish! if series_course.status == 'Unreviewed'
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
    render json: @course.as_json(methods: [:channel_fee, :chalkle_fee, :processing_fee, :teacher_max_income, :teacher_min_income, :channel_min_income, :channel_max_income, :teacher_pay_variable, :teacher_pay_flat])
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

    def take_me_to
      if params[:search].present?
        try_id = params[:search] 
        course = Course.find_by_id try_id if try_id =~ /^\d+$/
        return redirect_to course.path if course.present? && policy(course).read?
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

    def load_course
      @course = Course.find_by_id(params[:id]).try :decorate
      return not_found if !@course
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
      unless !@course || policy(@course).read?
        unless @course.published?
          flash[:notice] = "This class is no longer available."
          redirect_to :root
          return false
        end
      end
    end

    def courses_for_time
      @courses_for_time ||= Querying::CoursesForTime.new(courses_base_scope)
    end

    def get_current_week(start_date = Date.current)
      if params[:day]
        begin
          Week.containing(Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i))
        rescue
          Week.containing(start_date)
        end
      else
        Week.containing(start_date)
      end
    end

    def decorate(courses)
      CourseDecorator.decorate_collection(courses)
    end

end