class LessonsController < ApplicationController
  def show
    @channel = Channel.find params[:channel_id]
    @channel.name == 'Horowhenua' || not_found
    @lesson = @channel.lessons.find params[:id]
  end
end