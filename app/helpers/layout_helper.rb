module LayoutHelper

  def page_title
    return @page_title if @page_title.present?
    if @channel_teacher.present? && @channel_teacher.id.present?
      title = @channel_teacher.name
    elsif @course.present? && @course.id.present?
      title = link_to @course.name, @course.path
    elsif @channel.id.present?
      title = @channel.name
    elsif @category.id.present?
      title = @category.name
    elsif @region.id.present? || @region.name == "New Zealand"
      if @courses.present?
        title = @region.name
      end
    end
    title || ''
  end

  def page_title_logo
    return @page_title_logo if @page_title_logo.present?
    if @channel_teacher.present? && @channel_teacher.id.present? 
      if @channel_teacher.avatar.present?
        @channel_teacher.avatar
      end
    elsif @course.present? && @course.id.present?
      @course.course_upload_image
    elsif @channel.logo.present?
      @channel.logo
    end
  end

  def page_subtitle
    return @page_subtitle if @page_subtitle.present?
    subtitle = ''
    if @channel_teacher.present? && @channel_teacher.id.present?
        subtitle = link_to @channel_teacher.channel.name, channel_path(@channel_teacher.channel.url_name)
    elsif @course.present? && @course.id.present?
        subtitle = link_to @course.channel.name, channel_path(@course.channel.url_name)
    elsif @teaching.present?
      
    elsif @courses
      if @channel.id.present?
        subtitle += @region.name+' '    if @region.id.present?
        subtitle += @category.name+' '  if @category.id.present?
        subtitle += ' classes from'
      elsif @category.id.present?
        subtitle += @region.name+' '    if @region.id.present?
        subtitle += ' classes in'
      elsif @region.id.present? || @region.name == "New Zealand"
        subtitle += ' classes in'
      end
    end
    subtitle || ''
  end

  def meta_title
    return @meta_title if @meta_title
    meta_title = ''
    if params[:action] == 'index' && params[:controller] == 'courses'
      meta_title = page_subtitle+' '+page_title
    elsif !@channel.new_record? && params[:controller] == 'channels'
      meta_title = @channel.name
    elsif params[:action] == 'new'
      meta_title = 'New '+ page_title
    elsif @course && !@course.new_record?
      meta_title = @course.name
    elsif @teaching && @teaching.editing_id
      meta_title = @teaching.title
    end
    meta_title += ' |' if meta_title
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
    if @channel_teacher.present? && @channel_teacher.id.present?
      if @channel_teacher.channel.hero.present?
        {
          default: @channel_teacher.channel.hero,
          blurred: @channel_teacher.channel.hero.blurred
        }
      end
    elsif @channel.hero.present?
        {
          default: @channel.hero,
          blurred: @channel.hero.blurred
        }
    elsif @booking && !@booking.new_record? && @booking.course.channel.hero.present?
        {
          default: @booking.course.channel.hero,
          blurred: @booking.course.channel.blurred
        }
    elsif @bookings && @bookings.first.course.channel.hero.present?
        {
          default: @bookings.first.course.channel.hero,
          blurred: @bookings.first.course.channel.hero.blurred
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
    if @channel_teacher.present? && @channel_teacher.id.present?
      nav_links << {
        img_name: "bolt",
        link: channel_channel_teacher_path(@channel_teacher.channel.url_name,@channel_teacher.id),
        active: action_parts.include?("show"),
        title: "Upcoming Classes"
      }
      if policy(@channel_teacher).edit?
        nav_links <<  {
          img_name: "settings",
          link: edit_channel_teacher_path(@channel_teacher),
          active: action_parts.include?("edit"),
          title: "Edit"
        }
      end
    elsif @booking.present?
    elsif @course.present? && @course.id.present?
      if @course.spaces_left?
        nav_links << {
          img_name: "bolt",
          link: new_course_booking_path(@course.id),
          active: action_parts.include?("new"),
          title: "Join"
        }
      end
      if policy(@course).edit?
        nav_links << {
          img_name: "settings",
          link: edit_course_path(@course),
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
      nav_links << {
          img_name: "contact",
          link: channel_contact_path(@channel.url_name),
          active: action_parts.include?("contact"),
          title: "contact"
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
    elsif controller_parts.include?("me")
       nav_links << {
          img_name: "bolt",
          link: me_root_path,
          active: action_parts.include?("index"),
          title: "Dashboard"
        }
      nav_links << {
        img_name: "settings",
          link: me_preferences_path,
          active: action_parts.include?("show"),
          title: "Settings"
      }
    end
    nav_links
  end
end