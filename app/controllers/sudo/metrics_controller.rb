class Sudo::MetricsController < Sudo::BaseController
  before_filter :set_titles

  def index

    @bookings_chart = new_bookings_chart
    @signups_chart = new_chalkers_chart
    @chalkler_stats = {
      week: Chalkler.stats_for_dates(Date.current-1.week, Date.current), 
      month: Chalkler.stats_for_dates(Date.current-1.month, Date.current)
    }
    @booking_stats = {
      week: Booking.stats_for_dates(Date.current-1.week, Date.current), 
      month: Booking.stats_for_dates(Date.current-1.month, Date.current)
    }

  end


  protected

  def new_chalkers_chart

    LazyHighCharts::HighChart.new('graph') do |f|
      f.title(:text => "Weekly Signups")
      f.xAxis(:categories => Array.new(30){|i| d = i.weeks.ago.to_date; "#{d.day}/#{d.month}" }.reverse )
      f.series(:name => "Signups", :yAxis => 0, :data => Array.new(30) {|i|
        Chalkler.where('created_at BETWEEN ? AND ?', (i+1).weeks.ago, i.weeks.ago ).count
      }.reverse )

      f.chart({:defaultSeriesType=>"area"})
    end

  end

  def new_bookings_chart
    LazyHighCharts::HighChart.new('graph') do |f|
      f.title(:text => "Weekly Bookings")
      f.xAxis(:categories => Array.new(30) {|i| d = i.weeks.ago.to_date; "#{d.day}/#{d.month}" }.reverse )
      f.series(:name => "All Bookings", :yAxis => 0, :data => Array.new(30) {|i|
        Booking.where('created_at > ? AND created_at < ?',(i+1).weeks.ago, i.weeks.ago).count
      }.reverse )

      f.series(:name => "Free", :yAxis => 0, :data => Array.new(30) {|i|
        Booking.where('provider_fee = 0 AND created_at > ? AND created_at < ?',(i+1).weeks.ago, i.weeks.ago).count
      }.reverse )

      f.series(:name => "Paid", :yAxis => 0, :data => Array.new(30) {|i|
        Booking.where('provider_fee > 0 AND created_at > ? AND created_at < ?',(i+1).weeks.ago, i.weeks.ago).count
      }.reverse )
      f.legend(:align => 'center', :verticalAlign => 'bottom', :y => -30, :x => 0, :layout => 'horizontal',)


      f.chart({:defaultSeriesType=>"line"})
    end
  end



  def set_title
    @page_title = "Platform Metrics"
  end


end