class Chalklers::TeachingsController < Chalklers::BaseController
  def new
    @chalkler_teaching = Teaching.new(current_chalkler)
  end

  def create
  	@chalkler_teaching = Teaching.new(current_chalkler)
  	if @chalkler_teaching.submit(params[:teaching])
  	 redirect_to root_url
  	 flash[:notice] = "Your class has been submitted"
  	else
      render 'new'
  	end
  end

  def show

  end


end
