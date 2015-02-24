class ChalklerDecorator < Draper::Decorator
  delegate_all

  def provider_links(style = '')
    source.providers.visible.collect { |c|
      if c.url_name?
        url = "http://#{c.url_name}.chalkle.com/"
      else
        url = h.provider_path(c)
      end
      h.link_to(c.name, url, { style: style })
    }.join(' | ')
  end

end