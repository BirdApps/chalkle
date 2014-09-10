class CoursesController < ApplicationController
  before_filter :load_course, only: [:show]
  before_filter :check_course_visibility, only: [:show]
  before_filter :authenticate_chalkler!, only: [:new]
  before_filter :expire_filter_cache, only: [:create, :update, :destroy]
  before_filter :check_clear_filters, only: [:index]

  def index
    @courses = Course.displayable.in_week(Week.containing(current_date)).by_date

    filter_courses

    @header_bg = @region.hero
    @header_blur_bg = @region.hero_blurred
  end

  def show
    not_found if !@course
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
      redirect_to course_url new_course_ids[0]
    else
      render 'new'
    end
  end

  def edit
    course = Course.find params[:id]
    authorize course
    @teaching = Teaching.new current_user
    @teaching.course_to_teaching course
  end

  def update
    course = Course.find params[:id]
    @teaching = Teaching.new current_user
    if params[:teaching_agreeterms] == 'on'
      success = @teaching.update course, params[:teaching]
    end
    if success
      redirect_to course_url course.id
    else
      render 'new'
    end
  end

  def destroy

  end
  
  def change_status
    course = Course.find params[:id]
    authorize course
    course.status = params[:course][:status]
    course.save
    redirect_to course_url course.id
  end

   def calculate_cost
    @course = Course.new(params[:course], as: :admin)
    @course.update_costs
    render json: @course.as_json(methods: [:channel_fee, :chalkle_fee])
  end

  private

    def filter_courses
      if @region.id.present? && @category.id.present? && @channel.id.present?
        @courses = @courses.in_region(@region).in_category(@category).in_channel(@channel)
      elsif @region.id.present? && @category.id.present? && @channel.id.nil?    
        @courses = @courses.in_region(@region).in_category(@category) 
      elsif @region.id.present? && @category.id.nil? && @channel.id.present?
        @courses = @courses.in_region(@region).in_channel(@channel)
      elsif @region.id.nil? && @category.id.present? && @channel.id.present?  
        @courses = @courses.in_category(@category).in_channel(@channel)
      elsif @region.id.nil? && @category.id.nil? && @channel.id.present?  
        @courses = @courses.in_channel(@channel)
      elsif @region.id.nil? && @category.id.present? && @channel.id.nil? 
        @courses = @courses.in_category(@category)   
      elsif @region.id.present? && @category.id.nil? && @channel.id.nil?
        @courses = @courses.in_region(@region)
      end
      if params[:search].present?
        @courses = Course.search params[:search], @courses
      end

      check_presence_of_courses
    end

    def load_course
      @course = start_of_association_chain.find(params[:id]).decorate
    end     
 
    def geography_filter
      if @region
        filter = Filters::Filter.new
        filter.rules.build(strategy_name: 'single_region', value: @region)
        filter
      end
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
        @region = Region.new name: "New Zealand", courses: Course.all
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
      unless policy(@course).edit?
        unless @course.published?
          flash[:notice] = "This class is no longer available."
          redirect_to root_url
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

    def get_current_week(start_date = Date.today)
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