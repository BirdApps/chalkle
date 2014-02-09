class LessonsController < ApplicationController
  include Filters::FilterHelpers

  after_filter :store_location, only: [:show, :index]
  before_filter :load_channel
  before_filter :load_lesson, only: :show
  before_filter :redirect_meetup_lessons, only: :show
  layout 'new'

  def show
    week = get_current_week(@lesson.start_on || Date.today)
    @week_lessons = lessons_for_time.load_week_lessons(week)
  end

  def month
    @month_lessons = lessons_for_time.load_month_lessons get_current_month
  end

  def week
    @week_lessons = lessons_for_time.load_week_lessons(get_current_week)
  end

  def index
    month
    @filter = current_filter
    @region_filter = @filter.current_or_empty_filter_for('single_region')
    @channel_filter = @filter.current_or_empty_filter_for('single_channel')
    @category_filter = @filter.current_or_empty_filter_for('single_category')
    @week_lessons = lessons_for_time.load_upcoming_week_lessons(get_current_week)
  end

  def calculate_cost
    @lesson = Lesson.new(params[:lesson], as: :admin)
    @lesson.update_costs
    render json: @lesson.as_json(methods: [:channel_fee, :chalkle_fee])
  end

  private

    def load_lesson
      @lesson = start_of_association_chain.find(params[:id]).decorate
    end

    def redirect_meetup_lessons
      if @lesson.meetup_url.present?
        redirect_to @lesson.meetup_url
        return false
      end
    end

    def lessons_for_time
      @lessons_for_time ||= Querying::LessonsForTime.new(lessons_base_scope)
    end

    def start_of_association_chain
      @channel ? @channel.lessons : Lesson
    end

    def lessons_base_scope
      apply_filter(start_of_association_chain.published.by_date)
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

    def decorate(lessons)
      LessonDecorator.decorate_collection(lessons)
    end

    def load_channel
      @channel ||= Channel.find(params[:channel_id]) if params[:channel_id]
    end
end