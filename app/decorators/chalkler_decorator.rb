class ChalklerDecorator < Draper::Decorator
  delegate_all

  def channel_links(style = '')
    source.channels.visible.collect { |c|
        if c.url_name?
          url = "http://www.meetup.com/#{c.url_name}/events/calendar/?scroll=true"
        elsif
          url = h.channel_url(c)
        end
        h.link_to(c.name, url, { style: style })
    }.join(' | ')
  end

end