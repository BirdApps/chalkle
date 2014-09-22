class ChalklersController < ApplicationController
  def index
    @chalklers = Chalkler.visible
  end

  def show
    @chalkler = Chalkler.visible.find params[:id]
  end

  def exists
    authorize Chalkler.new
    if params[:email].present? && Chalkler.find_by_email(params[:email]).present?
      render json: true 
    else
      render json: false
    end

  end

end