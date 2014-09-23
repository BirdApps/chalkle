module LayoutHelper

  def page_title
    return @page_title if @page_title.present?
    if @teacher.present?
      @teacher.name
    elsif @channel.id.present?
      @channel.name
    elsif @category.id.present?
      @category.name
    elsif @region.id.present? || @region.name == "New Zealand"
      if @courses.present?
        @region.name
      end
    else
      'Chalkle'
    end
  end

  def title_size_class(title)
    'limit-size' if title.length > 25
  end

  def page_title_logo
    return @page_title_logo if @page_title_logo.present?
    if @teacher.present? 
      if @teacher.avatar.present?
        @teacher.avatar
      end
    elsif @channel.logo.present?
      @channel.logo
    end
  end

  def page_subtitle
    return @page_subtitle if @page_subtitle.present?
    subtitle = ''
    if @courses
      if @teacher.present?
        subtitle = link_to @teacher.channel.name, channel_path(@teacher.channel.url_name)
      elsif @channel.id.present?
        subtitle += @region.name+' '    if @region.id.present?
        subtitle += @category.name+' '  if @category.id.present?
        subtitle += ' classes from'
      elsif @category.id.present?
        subtitle += @region.name+' '    if @region.id.present?
        subtitle += ' classes in'
      elsif @region.id.present? || @region.name == "New Zealand"
        subtitle += ' classes in'
      else
        ''
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
      meta_title = 'New '+ page_title
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
    if @teacher.present?
      if @teacher.channel.hero.present?
        {
          default: @teacher.channel.hero,
          blurred: @teacher.channel.hero.blurred
        }
      end
    elsif @channel.hero.present?
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
    return @page_context_links if @page_context_links.present?
    controller_parts = request.path_parameters[:controller].split("/")
    action_parts = request.path_parameters[:action].split("/")
    nav_links = []
    if @teacher.present?
      if policy(@teacher).edit?
        nav_links << {
          img_name: "bolt",
          link: channel_teacher_path(@teacher.id),
          active: action_parts.include?("show"),
          title: "Upcoming Classes"
        }
        nav_links <<  {
          img_name: "settings",
          link: edit_channel_teacher_path(@teacher.id),
          active: action_parts.include?("edit"),
          title: "Edit"
        }
      end
    elsif @channel.id.present?
      nav_links << {
          img_name: "bolt",
          link: channel_path(@channel.url_name),
          active: action_parts.include?("show"),
          title: "Classes"
        }
      nav_links << {
          img_name: "people",
          link: channels_teachers_path(@channel.url_name),
          active: action_parts.include?("teachers") || controller_parts.include?("channel_teachers") ,
          title: "People"
        }
      # if policy(@channel).metrics?
      #   nav_links << {
      #     img_name: "metrics",
      #     link: metrics_path,
      #     active: action_parts.include?("metrics"),
      #     title: "Metrics"
      #   }
      # end
      # if policy(@channel).resources?
      #   nav_links <<  {
      #     img_name: "book",
      #     link: resources_path,
      #     active: action_parts.include?("resources"),
      #     title: "Resources"
      #   }
      # end
      if policy(@channel).edit?
        nav_links <<  {
          img_name: "settings",
          link: channel_settings_path(@channel.url_name),
          active: action_parts.include?("resources"),
          title: "Settings"
        }
      end
    end
    nav_links
  end
end