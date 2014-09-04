class ChalklersController < ApplicationController
  def index
    @chalklers = Chalkler.visible
  end

  def show
    @chalkler = Chalkler.visible.find params[:id]
  end

end