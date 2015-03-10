module LayoutHelper

  def get_coords
    longitude = session[:longitude] || current_user.longitude
    latitude = session[:latitude] || current_user.latitude
    location = session[:location] || current_user.location
    {lng: longitude, lat: latitude, location: location}
  end

  def environment_color(env)
    case env
    when "Development"
      return "default"
    when "Staging"
      return "info"
    when "Production"
      return "warning"
    end
  end

  def meta_title
    return @meta_title if @meta_title
    meta_title = ''
    if params[:action] == 'index' && params[:controller] == 'courses'
      meta_title = page_title
    elsif @provider.present? && !@provider.new_record? && params[:controller] == 'providers'
      meta_title = @provider.name
    elsif params[:action] == 'new'
      meta_title = 'New '+ page_title
    elsif @course.present? && !@course.new_record?
      meta_title = @course.name
    elsif @teaching.present? && @teaching.editing_id
      meta_title = @teaching.title
    end
    meta_title += ' ' if meta_title
    meta_title.downcase.gsub('course', 'class')
  end

  def page_hero
    @hero || "/assets/partners/index-hero.jpg" if @header_partial.present?
  end

  def nav_links
    @nav_links ||= []
  end

  def page_title
    @page_title ||= ""
  end

  def page_title_logo
    @page_title_logo ||= ""
  end

end