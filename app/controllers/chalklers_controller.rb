class ChalklersController < ApplicationController
  before_filter :load_chalkler, only: [:show]
  before_filter :header_chalkler, only: [:show]
  before_filter :page_titles, only: [:show]
  
  def index
    @chalklers = Chalkler.visible
  end

  def show
    authorize @chalkler
    @upcoming_courses = current_user.courses if @chalkler == current_user || current_user.super?
  end

  def exists
    if Chalkler.exists? params[:email]
      render json: true
    else
      render json: false
    end
  end

  def set_location

    session[:longitude] = params[:longitude]
    session[:latitude] = params[:latitude]
    session[:location] = params[:location]
    if current_user.authenticated?
      current_chalkler.longitude =  params[:longitude]
      current_chalkler.latitude =  params[:latitude]
      current_chalkler.location =  params[:location]
      current_chalkler.save if current_chalkler.changed?
    end
    render json: true
  end

  def get_location
    reconnect_attempts ||= 3
    begin
      if request && request.location && request.location.data
        lng = request.location.data["longitude"]
        lat = request.location.data["latitude"]
        location = request.location.data["region_name"]
      end
    rescue 
      retry if (reconnect_attempts -=1) > 0
    else
      lng = 0
      lat = 0
      location = ''
    end

    render json: {lng: lng, lat: lat, location: location};
  end

  private

    def load_chalkler
      @chalkler = Chalkler.find params[:id]
      return not_found if !@chalkler
    end

    def page_titles
      @page_title = @chalkler.name
      @page_title_logo = @chalkler.avatar
    end

end