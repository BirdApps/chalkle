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
      meta_title = page_subtitle+' '+page_title
    elsif !@provider.new_record? && params[:controller] == 'providers'
      meta_title = @provider.name
    elsif params[:action] == 'new'
      meta_title = 'New '+ page_title
    elsif @course && !@course.new_record?
      meta_title = @course.name
    elsif @teaching && @teaching.editing_id
      meta_title = @teaching.title
    end
    meta_title += ' ' if meta_title
    meta_title.downcase.gsub('course', 'class')
  end

  def page_hero
    @header_bg ? @header_bg : find_hero
  end

  def filter_params(type, value, include_type = nil)
    types = %w( provider search take start end )
    types << include_type if include_type
    params_copy = Hash.new
    types.each do |type_i|
      params_copy[type_i.to_sym] = params[type_i.to_sym]
    end
    if(types.include? type)
        params_copy[type.to_sym] = value
    end
    params_copy
  end

  def page_title
    @page_title ||= ""
  end

  def page_subtitle
    @page_subtitle ||= ""
  end

  def page_title_logo
    @page_title_logo ||= ""
  end

  def find_hero
    if @provider_teacher.present? && @provider_teacher.id.present? && @provider_teacher.provider.hero.present?
        {
          default: @provider_teacher.provider.hero,
          blurred: @provider_teacher.provider.hero.blurred
        }

    elsif @provider.hero.present?
        {
          default: @provider.hero,
          blurred: @provider.hero.blurred
        }
    elsif @booking && !@booking.new_record? && @booking.course.provider.hero.present?
        {
          default: @booking.course.provider.hero,
          blurred: @booking.course.provider.hero.blurred
        }
    elsif @bookings && @bookings.any? && @bookings.first.course.provider.hero.present?
        {
          default: @bookings.first.course.provider.hero,
          blurred: @bookings.first.course.provider.hero.blurred
        }
      else
        {
          default: '/assets/partners/index-hero.jpg',
          blurred: '/assets/partners/index-hero-invert.jpg'
        }
      end
  end
end