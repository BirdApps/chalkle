class LessonDecorator < Draper::Decorator
  delegate_all

  def channel_list
    return if source.channels.blank?
    source.channels.map{ |c| c.name.capitalize }.join(', ')
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
  
  def account
    channels.first.account? ? channels.first.account : "Please email accounts@chalkle.com for payment instructions"
  end

end