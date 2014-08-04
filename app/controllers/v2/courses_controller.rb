class V2::CoursesController < V2::BaseController
  include Filters::FilterHelpers
  before_filter :load_course, only: [:show]

  def index
    @courses_weeks = courses_for_time.load_upcoming_week_courses get_current_week
  end

  def show
    not_found if !@course
  end


  def new

  end

  def create

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
  
  def courses_for_time
    @courses_for_time ||= Querying::CoursesForTime.new courses_base_scope
  end

  def courses_base_scope
    apply_filter start_of_association_chain.published.by_date
  end

  def start_of_association_chain
    @channel ? @channel.courses : Course
  end

  def get_current_week( start_date = Date.today )
    if params[:day]
      Week.containing Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    else
      Week.containing start_date
    end
  end
end