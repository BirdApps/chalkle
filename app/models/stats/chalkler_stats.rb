class Chalkler_stats
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

  def new_chalklers
    channel.new_chalklers(start,end_time).count
  end

  def percent_active
    if channel.chalklers.empty?
      return 0
    else
      return (100.0*active_chalklers / channel.all_chalklers(end_time).count)
    end
  end

  private

  def end_time
    start + period
  end

  def active_chalklers
    end_date = (end_time - 3.months).midnight
    channel.chalklers.joins{bookings.outer}.where{(bookings.created_at.gt end_date.utc) | (chalklers.created_at.gt end_date.utc)}.select("chalklers.id").count
  end

end
