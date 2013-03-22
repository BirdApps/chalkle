class Chalklers::TeachingsController < Chalklers::BaseController
  def new
    @chalkler_teaching = Teaching.new(current_chalkler)
  end

  def create
  	@chalkler_teaching = Teaching.new(current_chalkler)
  	if @chalkler_teaching.submit(params[:teaching])
      session[:teachings_channel_email] = Channel.find(params[:teaching][:channel_id]).email
  	  redirect_to success_chalklers_teachings_url(request.parameters), notice: 'Your class has been saved.'
  	else
      render 'new'
  	end
  end

  def success
    @channel_email = session[:teachings_channel_email]
    session[:teachings_channel_email] = nil
  end

  def show
  end

end
