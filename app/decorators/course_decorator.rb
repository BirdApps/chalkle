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
    [['0 guests', 0], ['1 guest', 1], ['2 guests', 2], ['3 guests', 3], ['4 guests', 4]].take(source.spaces_left - 1)

  end

  def url
    h.channel_course_url(source.channel, source)
  end

end