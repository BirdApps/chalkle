class ChannelsController < ApplicationController
  def show
    @channel = Channel.find params[:id]
    @channel.name == 'Horowhenua' || not_found
    @lessons = @channel.lessons.visible.published.where{lessons.start_at > Time.now.utc}.order("start_at").decorate
  end
end