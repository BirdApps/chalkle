class StatsPolicy

  def initialize(start_date)
    @start_date = start_date
  end

  def stats_begin_date
  	@start_date.end_of_week(start_day= :wednesday).midnight
  end

end
