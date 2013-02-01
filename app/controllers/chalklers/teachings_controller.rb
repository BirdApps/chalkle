class Chalklers::TeachingsController < Chalklers::BaseController
  def new
    @chalkler_teaching = Teaching.new(current_chalkler)
  end

  def create
  	@chalkler_teaching = Teaching.new(current_chalkler)
  	if @chalkler_teaching.update_attributes(params[:teaching])
  		redirect_to root_url
  		flash[:success] = "Your class has been submitted"
  	else
  		flash[:notice] = "There is an error in submitting your class"
  		render 'new'
  	end
  end

  def show

  end


end
