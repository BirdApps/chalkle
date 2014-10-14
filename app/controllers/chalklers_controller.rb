class ChalklersController < ApplicationController
  def index
    @chalklers = Chalkler.visible
  end

  def show
    @chalkler = Chalkler.find params[:id]
    return not_found if !@chalkler
    authorize @chalkler
    @page_subtitle = '<a href="/people">Chalklers</a>'.html_safe
    @page_title = @chalkler.name
    @page_title_logo = @chalkler.avatar
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