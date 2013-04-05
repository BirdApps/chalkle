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
    channel.new_chalklers2(start,end_time).count
  end

  def percent_active
    if channel.chalklers.empty?
      return 0
    else
      return (100.0*active_chalklers / channel.chalklers.count)
    end
  end

  def attendee
    l = channel.lesson_ran2(start,end_time)
    total = 0
    l.each do |lesson|
      total = total + lesson.attendance
    end
    return total
  end

  def fill_fraction
    l = channel.lesson_ran2(start,end_time)
    total = 0
    l.each do |lesson|
      if lesson.attendance > 0
        total = total + lesson.attendance.to_d / (lesson.max_attendee.present? ? lesson.max_attendee.to_d : lesson.attendance.to_d)
      end
    end
    if l.length > 0
      return total / l.length*100
    else
      return 0
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
