class V2::People::TeachersController < V2::BaseController
  def index
    @teachers = ChannelTeacher.where(channel_id: params[:channel_id]).compact
    respond_to do |format|
      format.json { render json: @teachers.to_json(only: [:id, :name]) }
      format.html { render @teachers }
    end
  end

  def show

  end
end