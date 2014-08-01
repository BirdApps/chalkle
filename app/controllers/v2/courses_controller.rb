class V2::CoursesController < V2::BaseController

  def index
    @courses = Course.includes(:channel).limit(5)
  end

  def show
    @course = Course.includes(:channel).find params[:id]
    not_found if !@course
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