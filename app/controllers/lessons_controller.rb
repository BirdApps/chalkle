class LessonsController < ApplicationController
  before_filter :horowhenua?

  def show
    @channel = Channel.find params[:channel_id]
    @lesson = @channel.lessons.find(params[:id]).decorate
  end
end