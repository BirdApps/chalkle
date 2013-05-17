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
      "Join this class"
    end
  end

  def account
    if source.channels.first.account?
      source.channels.first.account
    else
      "Please email accounts@chalkle.com for payment instructions"
    end
  end

  def formatted_price
    if source.cost == 0 || source.cost.nil?
      'Free'
    else
      h.number_to_currency source.cost
    end
  end

  def guest_values
    [['Just me', 0], [2, 1], [3, 2], [4, 3], [5, 4]]
  end

end