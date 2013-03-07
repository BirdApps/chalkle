# encoding: UTF-8
module ApplicationHelper
  def title(page_title)
    content_for :title, page_title.to_s + " | chalkle°"
  end
  
  def channel_plural?(object, word)
    object.channels.length > 1 ? word + "s" : word
  end
end
