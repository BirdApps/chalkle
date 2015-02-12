class Sudo::MetricsController < Sudo::BaseController

  def index

    @bookings_chart = new_bookings_chart
    @signups_chart = new_chalkers_chart
    @courses_chart = new_courses_chart

    @course_stats = {
      total: Course.published.in_past.count
    }

    @provider_stats = {
      total: Provider.all.count
    }


    @chalkler_stats = {
      week: Chalkler.stats_for_date_and_range(Date.current, :week), 
      month: Chalkler.stats_for_date_and_range(Date.current, :month),
      total: Chalkler.signed_in_since(Date.current-100.years).count
    }

    @booking_stats = {
      total: Booking.all.count,
      week: Booking.stats_for_date_and_range(Date.current, :week), 
      month: Booking.stats_for_date_and_range(Date.current, :month)
    }

  end


  protected


  def new_courses_chart

    LazyHighCharts::HighChart.new('graph') do |f|
      f.title(:text => "")
      f.xAxis(:categories => Array.new(12){|i| d = i.months.ago.to_date; "#{d.strftime("%b")}" }.reverse )
      f.series(:name => "Courses run", :yAxis => 0, :data => Array.new(12) {|i|
        Course.start_at_between(i.months.ago, i.months.ago+1.month).count
      }.reverse )

      f.chart({:defaultSeriesType=>"area"})
    end

  end


  def new_chalkers_chart

    LazyHighCharts::HighChart.new('graph') do |f|
      f.title(:text => "Weekly Signups")
      f.xAxis(:categories => Array.new(30){|i| d = i.weeks.ago.to_date; "#{d.day}/#{d.month}" }.reverse )
      f.series(:name => "Signups", :yAxis => 0, :data => Array.new(30) {|i|
        Chalkler.created_week_of(i.weeks.ago).count
      }.reverse )

      f.chart({:defaultSeriesType=>"area"})
    end

  end

  def new_bookings_chart
    LazyHighCharts::HighChart.new('graph') do |f|
      f.title(:text => "Weekly Bookings")
      f.xAxis(:categories => Array.new(30) {|i| d = i.weeks.ago.to_date; "#{d.day}/#{d.month}" }.reverse )
      f.series(:name => "All Bookings", :yAxis => 0, :data => Array.new(30) {|i|
        Booking.created_week_of(i.weeks.ago).count
      }.reverse )

      f.series(:name => "Free", :yAxis => 0, :data => Array.new(30) {|i|
        Booking.created_week_of(i.weeks.ago).confirmed.free.count
      }.reverse )

      f.series(:name => "Paid", :yAxis => 0, :data => Array.new(30) {|i|
        Booking.created_week_of(i.weeks.ago).confirmed.not_free.count
      }.reverse )
      f.legend(:align => 'center', :verticalAlign => 'bottom', :y => -30, :x => 0, :layout => 'horizontal')
      f.yAxis(max: 125)

      f.chart({:defaultSeriesType=>"line"})
    end
  end



  def set_title
    @page_title = "Platform Metrics"
  end


end