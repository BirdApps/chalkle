class LessonsController < ApplicationController
  before_filter :horowhenua?
  after_filter :store_location

  def show
    @channel = Channel.find params[:channel_id]
    @lesson = @channel.lessons.find(params[:id]).decorate
  end
end