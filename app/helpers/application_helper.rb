# encoding: UTF-8
module ApplicationHelper
  

  def title(page_title)
    content_for :title, "#{page_title} | chalkle°"
  end

  def body_class
    [controller_name, action_name].join('-')
  end

  def bootstrap_form_for(*params, &block)
    params[1][:defaults] = {input_html: {class: "form-control"}}
    simple_form_for(*params, &block)
  end


  def link_to_or_span(*params)
    link_to_unless *params do |name, href, options|
      content_tag :span, name, options
    end
  end
  
  def base_url
    request.protocol + request.domain + (request.port.nil? ? '' : ":#{request.port}")
  end

  def typekit_includes
    render 'layouts/typekit_includes' unless Rails.env.development?
  end

  def header_color
    if @channel && @channel.header_color || @course && @course.channel.header_color
      (@channel || @course.channel).header_color || @booking && @booking.course.channel.header_color
      (@channel || @course.channel || @booking.course.channel).header_color
    else
      nil
    end
  end

  def to_html(markdown)
    ("<div class='markdown'>#{RDiscount.new(markdown).to_html}</div>").html_safe
  end


  def nav_badge_format()
    yield < 1 ? "" : " (#{yield})"
  end

  def paginate_position
    return @paginate_position if @paginate_position
    page_num = params[:page].to_i > 0 ? params[:page].to_i-1 : 0 
    if page_num > paginate_count
      @paginate_position = paginate_count 
    else
      @paginate_position = page_num
    end
  end

  def paginate_count
    @paginate_count ||= (@pagination_list.count / paginate_take) + 1
  end

  def paginate_take
    @paginate_take ||= params[:take].to_i > 0 ? params[:take].to_i : 30
  end

  def paginate_skip
    @paginate_skip ||= paginate_position*paginate_take
  end

  def paginate_these(list)
    @pagination_list = list
    list.drop(paginate_skip).take(paginate_take)
  end

  def filter_regions
    courses = Course.displayable.in_future
    if @category.id.present? && @channel.id.present?
      courses = courses.in_category(@category).in_channel(@channel)
    elsif @category.id.present? && @channel.id.nil?    
      courses = courses.in_category(@category) 
    elsif @category.id.nil? && @channel.id.present?
      courses = courses.in_channel(@channel)
    end
    (courses.map &:region).compact.uniq.sort_by{|c| c.name.downcase } 
  end

  def filter_topics
    courses = Course.displayable.in_future
    if @region.id.present? && @channel.id.present?
      courses = courses.in_region(@region).in_channel(@channel)
    elsif @region.id.present? && @channel.id.nil?    
      courses = courses.in_region(@region) 
    elsif @region.id.nil? && @channel.id.present?
      courses = courses.in_channel(@channel)
    end
    (courses.map &:category).compact.uniq.sort_by{|c| c.name.downcase } 
  end

  def filter_providers
    courses = Course.displayable.in_future
    if @category.id.present? && @region.id.present?
      courses = courses.in_category(@category).in_region(@region)
    elsif @category.id.present? && @region.id.nil?    
      courses = courses.in_category(@category) 
    elsif @category.id.nil? && @region.id.present?
      courses = courses.in_region(@region)
    end
    (courses.map &:channel).compact.uniq.sort_by{|c| c.name.downcase }
  end

end
