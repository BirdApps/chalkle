class V2::ChannelsController < V2::BaseController

  def index

  end

  def show
    @channel = Channel.includes(:courses).find_by_url_name params[:channel_url_name]
    not_found if !@channel
  end

  def series 
    @channel = Channel.includes(:courses).find_by_url_name params[:channel_url_name]
    not_found if !@channel
    @courses = @channel.courses.where url_name: params[:course_url_name]
  end

  def new

  end

  def create

  end


  def edit

  end

  def update

  end


  def destroy

  end
end