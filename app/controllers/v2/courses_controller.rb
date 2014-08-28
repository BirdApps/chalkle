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
    if params[:teaching_agreeterms] == 'on' && @teaching.submit(params[:teaching])
      channel = Channel.find(params[:teaching][:channel_id]) unless params[:teaching][:channel_id].blank?
      session[:teachings_channel_email] = (channel && channel.email?) ? channel.email : 'learn@chalkle.com'
      redirect_to success_chalklers_teachings_url, notice: 'Class submitted! Your class will be reviewed and published shortly.'
    else
      render 'new'
    end
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