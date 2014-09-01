class V2::ChannelsController < V2::BaseController

  before_filter :load_channel, except: :index

  def index
    @channels = Channel.visible
  end

  def show
    not_found if !@channel
    @courses = @channel.courses.displayable
  end

  def series 
    not_found if !@channel
    @courses = @channel.courses.displayable.where url_name: params[:course_url_name]
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

  private 

  def load_channel
    @channel = Channel.includes(:courses).find_by_url_name params[:channel_url_name] if params[:channel_url_name]
  end
end