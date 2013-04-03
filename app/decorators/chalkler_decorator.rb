class ChalklerDecorator < Draper::Decorator
  delegate_all

  def meetup_channels(style = '')
    source.channels.collect { |c|
      h.link_to(c.name, "http://www.meetup.com/#{c.url_name}/events/calendar/?scroll=true", { style: style })
    }.join(' | ')
  end

end