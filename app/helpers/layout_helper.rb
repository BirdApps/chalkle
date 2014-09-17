module LayoutHelper

  def page_title
    return @page_title if @page_title.present?
    if @courses
      if @channel.id.present?
        @channel.name
      elsif @category.id.present?
        @category.name
      else 
        @region.name
      end
    else
      meta_title.gsub '|', ''
    end
  end

  def title_size_class(title)
    'limit-size' if title.length > 25
  end

  def page_title_logo
    if @channel.logo.present?
      @channel.logo
    end
  end

  def page_subtitle
    return @page_subtitle if @page_subtitle.present?
    subtitle = ''
    if @courses
      if @channel.id.present?
        subtitle += @region.name+' '    if @region.id.present?
        subtitle += @category.name+' '  if @category.id.present?
        subtitle += ' classes from'
      elsif @category.id.present?
        subtitle += @region.name+' '    if @region.id.present?
        subtitle += ' classes in'
      else 
        subtitle += ' classes in'
        @region.name
      end
    end
    subtitle
  end

  def meta_title
    return @meta_title if @meta_title.present?
    meta_title = ''
    if params[:action] == 'index' && params[:controller] == 'courses'
      meta_title = page_subtitle+' '+page_title
    elsif @channel.id.present? && params[:controller] == 'channels'
      meta_title = @channel.name
    elsif params[:action] == 'new'
      meta_title = 'New '+ params[:controller].singularize
    elsif @course && @course.id.present?
      meta_title = @course.name
    elsif @teaching && @teaching.editing_id.present?
      meta_title = @teaching.title
    end
    meta_title += ' |' if meta_title.present?
    meta_title.downcase.gsub('course', 'class')
  end

  def page_hero
    @header_bg ? @header_bg : find_hero
  end

  def filter_params(type, value)
    types = %w(region topic provider search)
    params_copy = Hash.new
    types.each do |type_i|
      params_copy[type_i.to_sym] = params[type_i.to_sym]
    end
    if(types.include? type)
      if value == 'all'
         params_copy[type.to_sym] = session[type.to_sym].nil? ? nil : 'all'
      else
        params_copy[type.to_sym] = value
      end
    end
    params_copy
  end

  def find_hero
    if @channel.hero.present?
        {
          default: @channel.hero,
          blurred: @channel.hero.blurred
        }
      elsif @category.hero.present?
        {
          default: @category.hero,
          blurred: @category.hero.blurred
        }
      elsif @region.hero.present?
        {
          default: @region.hero,
          blurred: @region.hero.blurred
        }
      else
        {
          default: '/assets/partners/index-hero.jpg',
          blurred: '/assets/partners/index-hero-invert.jpg'
        }
      end
  end

  def page_context_links 
     controller_parts = request.path_parameters[:controller].split("/")
    
    if controller_parts.index("resources")
      active_link = "resources"
    elsif controller_parts.index("metrics")
      active_link = "metrics"
    elsif controller_parts.index("chalklers")
      active_link = "people"
    else
      active_link = "courses"
    end

    nav_links = []

    if @channel.id.present?
          nav_links << {
                  img_name: "bolt",
                  link: channel_path(@channel.url_name),
                  active: active_link == "courses",
                  title: "Classes"
                }

    nav_links << {
                  img_name: "people",
                  link: channel_channel_teachers_path(@channel.url_name),
                  active: active_link == "people",
                  title: "People"
                }
      if policy(@channel).metrics?           
        nav_links  << {
                        img_name: "metrics",
                        link: metrics_path,
                        active: active_link == "metrics",
                        title: "Metrics"
                      }
      end
      if policy(@channel).resources? 
        nav_links <<  {
                        img_name: "book",
                        link: resources_path,
                        active: active_link == "resources",
                        title: "Resources"
                      }
      end
    end
    nav_links
  end
end