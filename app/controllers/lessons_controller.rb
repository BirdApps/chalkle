class LessonsController < ApplicationController
  after_filter :store_location
  before_filter :load_channel
  layout 'new'

  def show
    @lesson = start_of_association_chain.find(params[:id]).decorate
    week = get_current_week(@lesson.start_on || Date.today)
    @week_lessons = lessons_for_time.load_week_lessons(week)
  end

  def month
    @month_lessons = lessons_for_time.load_month_lessons get_current_month
  end

  def week
    @week_lessons = lessons_for_time.load_week_lessons(get_current_week)
  end

  def upcoming
    load_upcoming
  end

  def index
    month
    @week_lessons = lessons_for_time.load_upcoming_week_lessons(get_current_week)
    load_upcoming
  end

  private

    def lessons_for_time
      @lessons_for_time ||= Querying::LessonsForTime.new(start_of_association_chain)
    end

    def start_of_association_chain
      @channel ? @channel.lessons : Lesson
    end

    def load_upcoming
      @page = [params[:page].to_i, 1].max
      @upcoming_lessons = decorate lessons_scope.page(@page)
    end

    def lessons_base_scope
      start_of_association_chain.published.by_date
    end

    def get_current_month
      @month = if params[:year] && params[:month]
        Month.new(params[:year].to_i, params[:month].to_i)
      else
        Month.current
      end
    end

    def get_current_week(start_date = Date.today)
      if params[:day]
        Week.containing(Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i))
      else
        Week.containing(start_date)
      end
    end

    def lessons_scope
      start_of_association_chain.upcoming.order('start_at')
    end

    def decorate(lessons)
      LessonDecorator.decorate_collection(lessons)
    end

    def load_channel
      @channel ||= Channel.find(params[:channel_id]) if params[:channel_id]
    end
end