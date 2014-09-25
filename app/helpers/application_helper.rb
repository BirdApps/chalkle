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
    render 'layouts/typekit_includes'
  end

end
