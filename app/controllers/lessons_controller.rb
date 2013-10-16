class LessonsController < ApplicationController
  after_filter :store_location
  before_filter :load_channel
  layout 'new'

  def show
    @lesson = @channel.lessons.find(params[:id]).decorate
    load_enough_weeks(@lesson.start_on || Date.today)
  end

  def month
    load_month_lessons get_current_month, @channel
  end

  def week
    load_week_lessons get_current_week, @channel
  end

  def upcoming
    load_upcoming
  end

  def index
    month
    load_enough_weeks
    load_upcoming
  end

  private

    def load_upcoming
      @page = [params[:page].to_i, 1].max
      @upcoming_lessons = decorate lessons_scope.page(@page)
    end

    def load_enough_weeks(start_date = Date.today)
      get_current_weeks(start_date).each do |week|
        load_week_lessons week, @channel
      end
      while weeks_loaded_count < 4 && no_weekly_lessons?
        load_another_week(@channel)
      end
    end

    def load_another_week(channel)
      next_week = @week_lessons.keys.last.next
      load_week_lessons next_week, channel
    end

    def weeks_loaded_count
      @week_lessons.keys.length
    end

    def no_weekly_lessons?
      !@week_lessons.values.map(&:empty?).include?(false)
    end

    def load_month_lessons(month, channel)
      @month_lessons ||= {}
      @month_lessons[month] = group_by_day decorate lessons_for_month(month, channel)
    end

    def load_week_lessons(week, channel)
      @week_lessons ||= {}
      @week_lessons[week] = group_by_day decorate lessons_for_week(week, channel)
    end

    def lessons_for_month(month, channel)
      lessons_base_scope(channel).in_month(month)
    end

    def lessons_for_week(week, channel)
      lessons_base_scope(channel).in_week(week)
    end

    def lessons_base_scope(channel)
      channel.lessons.published.by_date
    end

    def get_current_month
      @month = if params[:year] && params[:month]
        Month.new(params[:year].to_i, params[:month].to_i)
      else
        Month.current
      end
    end

    def get_current_weeks(start_date = Date.today)
      current_week = get_current_week(start_date)
      result = [current_week]
      result << current_week.next if start_date.friday? || start_date.saturday? || start_date.sunday?
      result
    end

    def get_current_week(start_date = Date.today)
      if params[:day]
        Week.containing(Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i))
      else
        Week.containing(start_date)
      end
    end

    def lessons_scope
      @channel.lessons.upcoming.order('start_at')
    end

    def decorate(lessons)
      LessonDecorator.decorate_collection(lessons)
    end

    def load_channel
      @channel ||= Channel.find params[:channel_id]
    end

    def group_by_day(lessons)
      result = {}
      lessons.each do |lesson|
        date = lesson.start_at.to_date
        result[date] ||= []
        result[date] << lesson
      end
      result
    end
end