class Financial_stats
  include ActiveAttr::Model

  attr_accessor :start, :period, :channel

  validates_date :start, :allow_nil => false, :on_or_after => '2012-08-01'
  validates_date :period, :allow_nil => false, :on_after_after => 1.day
  validates :channel, :presence => { :message => "Must have a channel to calculate statistics on"}

  def initialize(start, period, channel)
    @start = start
    @period = period
    @channel = channel
  end

  def turnover
    l = channel.lesson_ran(offset_start,offset_end)
    total = 0.0
    l.each do |lesson|
      total = lesson.collected_revenue + total
    end
    return total
  end

  def cost
    l = channel.lesson_ran(offset_start,offset_end)
    total = 0.0
    l.each do |lesson|
      if lesson.teacher_payment.present?
        total = total + lesson.teacher_payment + (lesson.venue_cost.present? ? lesson.venue_cost : 0) + (lesson.material_cost.present? ? lesson.material_cost : 0) + lesson.cash_payment
      else
        total = total + lesson.attendance*(lesson.teacher_cost.present? ? lesson.teacher_cost : 0)
      end
    end
    return total
  end

  private
  def offset_start
    (Date.today() - start).to_i
  end

  def offset_end
    (Date.today() - (start + period)).to_i
  end

end
