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
    @no_search = true
    @teaching = Teaching.new current_user
  end

  def create
    @teaching = Teaching.new current_user
    if params[:teaching_agreeterms] == 'on'
      new_course_ids =  @teaching.submit params[:teaching]
      if new_course_ids
        binding.pry
        redirect_to v2_course_url new_course_ids[0]
      end
    end
    render 'new'
  end

  def edit

  end

  def update

  end

  def destroy

  end
  
 

  private

  def load_course
    @course = Course.includes(:channel).find params[:id]
  end
 
end