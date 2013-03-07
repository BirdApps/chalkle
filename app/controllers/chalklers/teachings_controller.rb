class Chalklers::TeachingsController < Chalklers::BaseController
  def new
    @chalkler_teaching = Teaching.new(current_chalkler)
  end

  def create
  	@chalkler_teaching = Teaching.new(current_chalkler)
  	if @chalkler_teaching.submit(params[:teaching])
  	 redirect_to success_chalklers_teachings_url
  	else
      render 'new'
  	end
  end

  def success
  end

  def show

  end


end
