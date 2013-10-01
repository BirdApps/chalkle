class LessonsController < ApplicationController
  #before_filter :horowhenua?
  after_filter :store_location

  def show
    load_channel
    @lesson = @channel.lessons.find(params[:id]).decorate
  end

  def index
    load_channel
    @lessons = LessonDecorator.decorate_collection @channel.lessons.upcoming.order('start_at').page(params[:page])
  end

  private

    def load_channel
      @channel = Channel.find params[:channel_id]
    end
end