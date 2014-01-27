class ChannelsController < ApplicationController
  after_filter :store_location
  layout 'new'

  before_filter :load_channel
  before_filter :redirect_meetup_channels, only: :show

  def show
    @month_lessons = lessons_for_time.load_month_lessons Month.current
    @week_lessons = lessons_for_time.load_upcoming_week_lessons Week.current
  end

  private

  def load_channel
    @channel = find_channel_by_subdomain || Channel.find(params[:id])
  end

  def find_channel_by_subdomain
    Channel.find_by_url_name(request.subdomain) if request.subdomain.present?
  end

  def redirect_meetup_channels
    if @channel.meetup_url.present?
      redirect_to @channel.meetup_url
      return false
    end
  end

  def lessons_for_time
    @lessons_for_time ||= Querying::LessonsForTime.new(@channel.lessons)
  end
end