class Chalklers::TeachingsController < Chalklers::BaseController
  def new
    @chalkler_teaching = Teaching.new(current_chalkler)
  end

  def create
  	@chalkler_teaching = Teaching.new(current_chalkler)
  	if @chalkler_teaching.submit(params[:teaching])
      channel = @chalkler_teaching.channels[params[:teaching][:channel_select].to_i - 1]
      session[:teachings_channel_email] = (channel.email?) ? channel.email : 'learn@chalkle.com'
  	  redirect_to success_chalklers_teachings_url, notice: 'Your class has been saved.'
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
