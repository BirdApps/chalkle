module ChannelsHelper
  def channel_logo(channel)
    url = if channel.logo.present?
      channel.logo.url
    else
      'http://placehold.it/165x165&text=' + URI.encode(channel.name)
    end
    image_tag url, class: 'channel_logo', alt: channel.name
  end

  def lesson_channel_link(lesson)
    channel = lesson.channel
    if channel
      names = [lesson.channel_name, lesson.region_name].reject(&:blank?).uniq
      content_tag(:div, nil, class: 'channel') do
        link_to names.join(', '), channel_path(channel)
      end
    end
  end
end