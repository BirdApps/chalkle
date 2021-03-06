# encoding: UTF-8
module ApplicationHelper
  
  def money_formatted(cost)
    sprintf('%.2f', cost || 0)
  end

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

  def datetime_to_nearest_5_minutes(t)
    rounded = Time.at((t.to_time.to_i / 300.0).round * 300).in_time_zone(current_user.timezone)
    t.is_a?(DateTime) ? rounded.to_datetime : rounded
  end
  
  def typekit_includes
    render 'layouts/typekit_includes'
  end

  def analytics_init
    render 'layouts/google_tracker'
  end

  def favicons
    render partial: 'layouts/favicon'
  end

  def open_graph_tags 
    render partial: 'layouts/open_graph_meta'
  end

  def header_color
    if @provider && @provider.header_color || @course && @course.provider.header_color
      (@provider || @course.provider).header_color || @booking && @booking.course.provider.header_color
      (@provider || @course.provider || @booking.course.provider).header_color
    else
      nil
    end
  end

  def show_header?
    return false if request[:controller] =~ /sessions/
    true
  end

  def truncate(string, length=16)
    return unless string
    truncated = string.split[0..string[0..length].split(" ").count-1].join(" ")
    if truncated[truncated.length-1]
      truncated[truncated.length-1] = truncated[truncated.length-1].gsub(/[^0-9A-Za-z]/, '')
      truncated
    else 
      ""
    end
  end

  def to_html(markdown)
    return "" if markdown == nil 
    "<div class='markdown'>#{markdown.to_html}</div>".html_safe
  end


  def nav_badge_format()
    yield < 1 ? "" : " (#{yield})"
  end

  def page_min
    if paginate_position + 3 > paginate_count
      min = paginate_count - 4
    else
      min = paginate_position - 2  
    end
    min = 0 if min < 0
    min
  end

  def page_max
    max = page_min + 4
    max = paginate_count if (max > (paginate_count))
    max
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
    @paginate_count ||= [(@pagination_list.count / paginate_take), 0].max
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

end
