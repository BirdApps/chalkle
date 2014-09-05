class CoursesController < ApplicationController
  before_filter :load_course, only: [:show]
  before_filter :course_nav_links, except: [:new]
  before_filter :authenticate_chalkler!, only: [:new]

  def index
    #@courses_weeks = courses_for_time.load_upcoming_week_courses get_current_week
    @courses = Course.in_week(Week.containing(current_date)).by_date
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
    course.status = params[:course][:status]
    course.save
    redirect_to course_url course.id
  end

  private

  def load_course
    @course = Course.includes(:channel).find params[:id]
  end
 
end