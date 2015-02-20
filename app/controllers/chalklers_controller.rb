class ChalklersController < ApplicationController
  before_filter :header_chalkler, only: [:show]
  before_filter :page_titles, only: [:show]
  
  def index
    @chalklers = Chalkler.visible
  end

  def show
    @chalkler = Chalkler.find params[:id]
    return not_found if !@chalkler
    authorize @chalkler
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

    def page_titles
      @page_subtitle = "[Chalklers](#{people_path})"
      @page_title = @chalkler.name
      @page_title_logo = @chalkler.avatar
    end

    def header_chalkler
      @nav_links = []

      if current_user.super?
       @nav_links << {
          img_name: "people",
          link: become_sudo_chalkler_path(@chalkler.id),
          active: false,
          title: "Become"
        }
      end

      if @chalkler == current_chalkler || current_user.super?
       @nav_links << {
          img_name: "settings",
          link: me_preferences_path,
          active: false,
          title: "Settings"
        }
      end

    end

end