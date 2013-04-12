class LessonDecorator < Draper::Decorator
  delegate_all

  def category_list
    return if source.categories.blank?
    "In #{source.categories.map(&:name).join(', ').titleize}" if categories.any?
  end

  def join_chalklers
    if source.attendance > 1
      "Join #{source.attendance} other chalklers"
    else
      "Join this chalkle"
    end
  end

end