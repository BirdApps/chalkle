module ProvidersHelper
  def provider_logo(provider)
    url = if provider.logo.present?
      provider.logo.url
    else
      'http://placehold.it/165x165&text=' + URI.encode(provider.name)
    end
    image_tag url, class: 'provider_logo', alt: provider.name
  end

  def course_provider_link(course)
    provider = course.provider
    if provider
      names = [course.provider_name, course.region_name].reject(&:blank?).uniq
      content_tag(:div, nil, class: 'provider') do
        link_to names.join(', '), url_for_provider(provider)
      end
    end
  end

  def url_for_provider(provider)
    root_url(subdomain: provider.url_name)
  end

  def provider_follow_link(provider)
    if current_chalkler
      if current_chalkler.is_following?(@provider)
        link_to "UNFOLLOW", provider_subscriptions_path(@provider), class: "subscribe_link", id: "js-subscribe", remote: true, method: :delete, "data-toggle" => 'tooltip', title: 'Stop including these classes in my updates'
      else
        link_to "FOLLOW", provider_subscriptions_path(@provider), class: "subscribe_link", id: "js-subscribe", remote: true, method: :post, "data-toggle" => 'tooltip', title: 'Include these classes in my updates'
      end
    else
      link_to "FOLLOW", new_chalkler_session_url, class: "subscribe_link", id: "js-subscribe", "data-toggle" => 'tooltip', title: 'Include these classes in my updates'
    end
  end
end