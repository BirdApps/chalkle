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
end
