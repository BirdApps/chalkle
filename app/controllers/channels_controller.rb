class ChannelsController < ApplicationController
  after_filter :store_location
  layout 'new'

  def show
    redirect_to channel_lessons_path(params[:id])
  end

  def home
    @channel = Channel.find(params[:id])
    @week_lessons = lessons_for_time.load_week_lessons(Week.current)
  end

  private

  def lessons_for_time
    @lessons_for_time ||= Querying::LessonsForTime.new(@channel.lessons)
  end

end