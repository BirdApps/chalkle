module ChannelsHelper
  def channel_logo(channel)
    url = if channel.logo.present?
      channel.logo.url
    else
      'http://placehold.it/165x165&text=' + URI.encode(channel.name)
    end
    image_tag url, class: 'channel_logo', alt: channel.name
  end
end