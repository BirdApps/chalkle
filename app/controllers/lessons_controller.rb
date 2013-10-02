class LessonsController < ApplicationController
  #before_filter :horowhenua?
  after_filter :store_location

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
    @month = Month.current
    @lessons = group_by_day decorate lessons_scope
  end

  private

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