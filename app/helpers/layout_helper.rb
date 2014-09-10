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
    @header_bg ? @header_bg : '/assets/partners/partners-hero.jpg'
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
end