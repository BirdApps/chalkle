class V2::CoursesController < V2::BaseController
  include Filters::FilterHelpers
  before_filter :load_course, only: [:show]
  before_filter :course_nav_links, except: [:new]
  before_filter :authenticate_chalkler!, only: [:new]

  def index
    @courses_weeks = courses_for_time.load_upcoming_week_courses get_current_week
    #@courses_weeks = Course.in_week get_current_week
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
      redirect_to v2_course_url new_course_ids[0]
    else
      render 'new'
    end
  end

  def edit
    course = Course.find params[:id]
    @teaching = Teaching.new current_user
    if course.course?
      @teaching.course_to_teaching course
    else
      @teaching.class_to_teaching course
    end
  end

  def update
    course = Course.find params[:id]
    @teaching = Teaching.new current_user
    if params[:teaching_agreeterms] == 'on'
      new_course_ids =  @teaching.update params[:teaching]
    end
    if new_course_ids
      redirect_to v2_course_url new_course_ids[0]
    else
      render 'new'
    end
  end

  def destroy

  end
  
  def change_status
   
  end

  private

  def load_course
    @course = Course.includes(:channel).find params[:id]
  end
 
end