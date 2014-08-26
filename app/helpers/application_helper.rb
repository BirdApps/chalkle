# encoding: UTF-8
module ApplicationHelper
  def title(page_title)
    content_for :title, "#{page_title} | chalkle°"
  end

  def title_content
    content_for?(:title) ? yield(:title) : 'chalkle°'
  end

  def thumbnail_image
    content_for?(:fb_thumbnail) ? yield(:fb_thumbnail) : asset_path('partners/chalkle@2x.png')
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
end
