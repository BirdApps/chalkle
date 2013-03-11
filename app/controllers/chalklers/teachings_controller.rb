class Chalklers::TeachingsController < Chalklers::BaseController
  def new
    @chalkler_teaching = Teaching.new(current_chalkler)
  end

  def create
  	@chalkler_teaching = Teaching.new(current_chalkler)
  	if @chalkler_teaching.submit(params[:teaching])
  	 redirect_to success_chalklers_teachings_url, notice: 'Your class has been saved.'
  	else
      render 'new'
  	end
  end

  def success
    @curator_email = current_chalkler.channels.first.email
  end

  def show

  end


end
