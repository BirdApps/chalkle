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
    l = channel.lesson_ran(start,end_time)
    total = 0.0
    l.each do |lesson|
      total = lesson.collected_revenue + total
    end
    total
  end

  def cost
    l = channel.lesson_ran(start,end_time)
    total = 0.0
    l.each do |lesson|
      total = lesson.total_cost + total
    end
    total
  end

  private

  def end_time
    start + period
  end

end
