class ChannelsController < ApplicationController
  after_filter :store_location
  layout 'new'

  before_filter :load_channel

  def show
    redirect_to channel_lessons_path(@channel)
  end

  def home
    @month_lessons = lessons_for_time.load_month_lessons Month.current
    @week_lessons = lessons_for_time.load_upcoming_week_lessons Week.current
  end

  private

  def load_channel
    @channel = Channel.find(params[:id])
  end

  def lessons_for_time
    @lessons_for_time ||= Querying::LessonsForTime.new(@channel.lessons)
  end

end