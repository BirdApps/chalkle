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

  def page_title
    return @page_title if @page_title.present?
    if @provider_teacher.present? && @provider_teacher.id.present?
      title = @provider_teacher.name
    elsif @course.present? && @course.id.present?
      title = link_to @course.name, @course.path
    elsif @provider.id.present?
      title = @provider.name
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
    if @provider_teacher.present? && @provider_teacher.id.present? 
      if @provider_teacher.avatar.present?
        @provider_teacher.avatar
      end
    elsif @course.present? && @course.id.present?
      @course.course_upload_image
    elsif @provider.logo.present?
      @provider.logo
    end
  end

  def page_subtitle
    return @page_subtitle if @page_subtitle.present?
    subtitle = ''
    if @provider_teacher.present? && @provider_teacher.id.present?
        subtitle = link_to @provider_teacher.provider.name, provider_path(@provider_teacher.provider.url_name)
    elsif @course.present? && @course.id.present?
        subtitle = link_to @course.provider.name, provider_path(@course.provider.url_name)
    elsif @teaching.present?
      
    elsif @courses
      if @provider.id.present?
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
    types = %w( topic region provider search take start end )
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
    return @page_context_links if @page_context_links
    controller_parts = request.path_parameters[:controller].split("/")
    action_parts = request.path_parameters[:action].split("/")
    nav_links = []
    if @provider_teacher.present? && @provider_teacher.id.present?
      nav_links << {
        img_name: "bolt",
        link: provider_provider_teacher_path(@provider_teacher.provider.url_name,@provider_teacher.id),
        active: action_parts.include?("show"),
        title: "Classes"
      }
      if policy(@provider_teacher).edit?
        nav_links <<  {
          img_name: "settings",
          link: edit_provider_teacher_path(@provider_teacher),
          active: action_parts.include?("edit"),
          title: "Edit"
        }
      end
      if current_user.super? && @provider_teacher.chalkler_id.present?
        nav_links <<  {
          img_name: "people",
          link: become_sudo_chalkler_path(@provider_teacher.chalkler_id),
          active: false,
          title: "Become"
        }
      end
    elsif @booking.present?
    elsif @course.present? && @course.id.present?
      if policy(@course).read?
        nav_links << {
            img_name: "bolt",
            link: course_bookings_path(@course),
            active: controller_parts.include?("bookings"),
            title: "Bookings"
          }
      elsif @course.spaces_left?
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
      if policy(@course).write?(true)
        nav_links << {
          img_name: "people",
          link: clone_course_path(@course),
          active: false,
          title: "Copy"
        }
      end
    elsif @provider.id.present?
      nav_links << {
          img_name: "bolt",
          link: provider_path(@provider.url_name),
          active: action_parts.include?("show"),
          title: "Classes"
        }
      nav_links << {
          img_name: "people",
          link: providers_teachers_path(@provider.url_name),
          active: action_parts.include?("teachers") || controller_parts.include?("provider_teachers") ,
          title: "People"
        }
      nav_links << {
          img_name: "contact",
          link: provider_contact_path(@provider.url_name),
          active: action_parts.include?("contact"),
          title: "contact"
        }
      # if policy(@provider).metrics?
      #   nav_links << {
      #     img_name: "metrics",
      #     link: metrics_path,
      #     active: action_parts.include?("metrics"),
      #     title: "Metrics"
      #   }
      # end
      # if policy(@provider).resources?
      #   nav_links <<  {
      #     img_name: "book",
      #     link: resources_path,
      #     active: action_parts.include?("resources"),
      #     title: "Resources"
      #   }
      # end
      if policy(@provider).edit?
        nav_links <<  {
          img_name: "settings",
          link: provider_settings_path(@provider.url_name),
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
      nav_links << {
        img_name: "plane", 
        link: me_notification_preference_path,
        active: action_parts.include?("notifications"),
        title: "Email Options"
      }
    end
    nav_links
  end
end