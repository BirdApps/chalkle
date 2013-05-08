class ChannelsController < ApplicationController
  def show
    @channel = Channel.find params[:id]
    @lessons = @channel.lessons.visible.published.where{lessons.start_at > Time.now.utc}.order("start_at").decorate
  end
end