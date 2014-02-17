class ChalklerDecorator < Draper::Decorator
  delegate_all

  def channel_links(style = '')
    source.channels.visible.collect { |c|
      if c.url_name?
        url = "http://#{c.url_name}.chalkle.com/"
      else
        url = h.channel_url(c)
      end
      h.link_to(c.name, url, { style: style })
    }.join(' | ')
  end

end