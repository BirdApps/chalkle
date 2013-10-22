class ChannelsController < ApplicationController
  after_filter :store_location

  def show
    redirect_to channel_lessons_path(params[:id])
  end
end