class ChannelsController < ApplicationController
  after_filter :store_location

  def show
    @channel = Channel.find params[:id]
    @lessons = LessonDecorator.decorate_collection @channel.lessons.upcoming.order('start_at').page(params[:page])
  end
end