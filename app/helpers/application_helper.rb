# encoding: UTF-8
module ApplicationHelper
  def title(page_title)
    content_for :title, page_title.to_s + " | chalkle°"
  end
end
