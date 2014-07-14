class BookingDecorator < Draper::Decorator
  delegate_all
  decorates_association :course
  decorates_association :chalkler

  def formatted_price
    if source.cost == 0 || source.cost.nil?
      'Free'
    else
      h.number_to_currency source.cost
    end
  end

end
