class LessonDecorator < Draper::Decorator
  delegate_all

  def channel_list
    return if source.channels.blank?
    if source.channels.count == 1
      "Channel: #{source.channels.first.name.titleize}"
    else
      "Channels: #{source.channels.map(&:name).join(', ')}"
    end
  end

  def category_list
    return if source.categories.blank?
    "In #{source.categories.map(&:name).join(', ').titleize}"
  end

  def join_chalklers
    if source.attendance > 1
      "Join #{source.attendance} other chalklers"
    else
      "Join this chalkle"
    end
  end

end