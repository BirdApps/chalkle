class ChannelTeachersController < ApplicationController
  before_filter :load_teacher, only: [:show]

  def index
    @teachers = ChannelTeacher.all
    respond_to do |format|
      format.json { render json: @teachers.to_json(only: [:id, :name]) }
      format.html { render @teachers }
    end
  end

  def show
    
  end

  private
    def load_teacher
      @teacher = ChannelTeacher.find params[:id]
    end
end