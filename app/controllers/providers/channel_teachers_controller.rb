class Providers::ChannelTeachersController < ApplicationController
  def index
    @teachers = ChannelTeacher.where(channel_id: params[:channel_id]).compact
    respond_to do |format|
      format.json { render json: @teachers.to_json(only: [:id, :name]) }
      format.html { render @teachers }
    end
  end

  def show
    #TODO: get chalkler and show all their channel_teachers
  end
end