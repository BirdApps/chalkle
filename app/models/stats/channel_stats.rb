class ChannelStats
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

  def financial_stats
    FinancialStats.new(start,period,channel)
  end

  def lesson_stats
    LessonStats.new(start,period,channel)
  end

  def chalkler_stats
    ChalklerStats.new(start,period,channel)
  end

  private

  def end_time
    start + period
  end

  private

  def percentage_change(initial, final)
    return if initial.nil?
    (initial > 0) ? (final / initial.to_d - 1)*100.0 : nil
  end

  def mean(input)
    input.compact!
    input.length > 0 ? input.sum / input.length : nil
  end

end
