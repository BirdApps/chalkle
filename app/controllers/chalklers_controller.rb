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
    @page_context_links = []
    if current_user.super?
     @page_context_links << {
        img_name: "people",
        link: becoming_sudo_chalklers_path(@chalkler.id),
        active: false,
        title: "Become"
      }
    end
    if @chalkler == current_chalkler
     @page_context_links << {
        img_name: "settings",
        link: me_preferences_path,
        active: false,
        title: "Settings"
      }
    end
    
  end

  def exists
    authorize Chalkler.new
    if Chalkler.exists? params[:email]
      render json: true
    else
      render json: false
    end
  end

end