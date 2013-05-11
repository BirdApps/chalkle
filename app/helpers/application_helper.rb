# encoding: UTF-8
module ApplicationHelper
  def title(page_title)
    content_for :title, "#{page_title} | chalkle°"
  end

  def body_class
    [controller_name, action_name].join('-')
  end
end
