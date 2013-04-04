class Financial_stats
  include ActiveAttr::Model

  attr_accessor :start_date, :period, :channel, :turnover, :cost

  validates_date :start_date, :allow_nil => false, :on_or_after => '2012-08-01'
  validates_date :period, :allow_nil => false, :on_after_after => 1.day
  validates :channel, :presence => { :message => "Must have a channel to calculate statistics on"}

  def initialize(start_date, period, channel_id)
    @start_date = start_date
    @period = period
    @channel = Channel.find(channel_id)
  end

  def begin_date
    start_date.to_date.to_s
  end

  def end_date
    (start_date + period).to_date.to_s
  end

  def turnover
    l = channel.lesson_ran(begin_date,end_date)
    total = 0.0
    l.each do |lesson|
      total = lesson.collected_revenue + total
    end
    return total
  end

  def cost
    l = channel.lesson_ran(begin_date,end_date)
    total = 0.0
    l.each do |lesson|
      if lesson.teacher_payment.present?
        total = total + lesson.teacher_payment + (lesson.venue_cost.present? ? lesson.venue_cost : 0) + (lesson.material_cost.present? ? lesson.material_cost : 0)
      else
        total = total + lesson.attendance*(lesson.teacher_cost.present? ? lesson.teacher_cost : 0)
      end
    end
    return total
  end
end
