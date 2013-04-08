class Stats_policy

  def initialize(end_date)
    @end_date = end_date
  end

  def stats_end_date
    @end_date.end_of_week(start_day= :wednesday).midnight
  end

end
