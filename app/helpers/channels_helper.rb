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

  def channel_follow_link(channel)
    if current_chalkler
      if current_chalkler.is_following?(@channel)
        link_to "UNFOLLOW", channel_subscriptions_path(@channel), class: "subscribe_link", id: "js-subscribe", remote: true, method: :delete, "data-toggle" => 'tooltip', title: 'Stop including these classes in my updates'
      else
        link_to "FOLLOW", channel_subscriptions_path(@channel), class: "subscribe_link", id: "js-subscribe", remote: true, method: :post, "data-toggle" => 'tooltip', title: 'Include these classes in my updates'
      end
    else
      link_to "FOLLOW", new_chalkler_session_path, class: "subscribe_link", id: "js-subscribe", "data-toggle" => 'tooltip', title: 'Include these classes in my updates'
    end
  end
end