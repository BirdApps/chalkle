class Chalklers::TeachingsController < Chalklers::BaseController
  def new
    @chalkler_teaching = Teaching.new(current_chalkler)
  end

  def create
  	@chalkler_teaching = Teaching.new(current_chalkler)
    if @chalkler_teaching.check_valid_input(params[:teaching])
  	  if @chalkler_teaching.submit()
  		  redirect_to root_url
  		  flash[:success] = "Your class has been submitted"
      end
  	else
      render 'new'
  	end
  end

  def show

  end


end
