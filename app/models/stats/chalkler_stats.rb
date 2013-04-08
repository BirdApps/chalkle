class ChalklerStats < ChannelStats

  def new_chalklers
    channel.new_chalklers(start,end_time).count
  end

  def previous
    ChalklerStats.new(start - period, period, channel)
  end

  def percent_new_chalklers
    percentage_change(previous.new_chalklers, new_chalklers)
  end

  def percent_active
    if channel.chalklers.empty?
      return 0
    else
      return (100.0*active_chalklers / channel.all_chalklers(end_time).count)
    end
  end

  private

  def active_chalklers
    end_date = (end_time - 3.months).midnight
    channel.chalklers.joins{bookings.outer}.where{(bookings.created_at.gt end_date.utc) | (chalklers.created_at.gt end_date.utc)}.select("chalklers.id").count
  end

end
