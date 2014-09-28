class CourseDecorator < ApplicationDecorator
  delegate_all

  def join_chalklers
    if source.attendance > 1
      "Join #{source.attendance} other chalklers"
    else
      "Join this class"
    end
  end

  def account
    if source.channel.account?
      source.channel.account
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
    guest_vals = [['No friends', 0], ['1 friend', 1], ['2 friends', 2], ['3 friends', 3], ['4 friends', 4]]
    guest_vals = guest_vals.take(source.spaces_left - 1) if source.limited_spaces?
    guest_vals
  end

  def url
    h.channel_course_url(source.channel, source)
  end

end