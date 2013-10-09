class LessonsController < ApplicationController
  #before_filter :horowhenua?
  after_filter :store_location
  layout 'new', only: :month

  def show
    load_channel
    @lesson = @channel.lessons.find(params[:id]).decorate
  end

  def index
    load_channel
    @lessons = decorate lessons_scope
  end

  def month
    load_channel
    load_month
    @lessons = group_by_day decorate lessons_for_month
  end

  private

    def lessons_for_month
      @channel.lessons.published.in_month(@month).by_date
    end

    def load_month
      @month = if params[:year] && params[:month]
        Month.new(params[:year].to_i, params[:month].to_i)
      else
        Month.current
      end
    end

    def lessons_scope
      @channel.lessons.upcoming.order('start_at')
    end

    def decorate(lessons)
      LessonDecorator.decorate_collection(lessons)
    end

    def load_channel
      @channel = Channel.find params[:channel_id]
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