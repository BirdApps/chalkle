class Sudo::MetricsController < Sudo::BaseController

  def index
    @month = Month.current
  end

  def overview
    if params[:month].present?
      date = params[:month].to_date 
      month = Month.new date.year, date.month
    else
      month = Month.current
    end

    @month = month
    @bookings_chart = new_bookings_chart(month)
    @signups_chart = new_chalkers_chart(month)
    @courses_chart = new_courses_chart(month)

    @course_stats = {
      total: Course.in_month(month).count,
      paid: Course.in_month(month).paid.count,
      free: Course.in_month(month).free.count
    }

    @user_stats = {
      total: Chalkler.where(created_at: month.first_day..month.last_day).count,
      learned: Chalkler.learned.where(created_at: month.first_day..month.last_day).count,
      taught: Chalkler.taught.where(created_at: month.first_day..month.last_day).count,
      provided: Chalkler.provided.where(created_at: month.first_day..month.last_day).count,
    }

    @provider_stats = {
      total: Channel.all.count,
      created: Channel.where(created_at: month.first_day..month.last_day).count
    }

    @chalkler_stats = {
      month: Chalkler.stats_for_date_and_range(month.first_day, :month),
      total: Chalkler.signed_in_since(Date.current-100.years).count
    }

    @booking_stats = {
      total: Booking.confirmed.count,
      month: Booking.stats_for_date_and_range( month.first_day, :month)
    }

    @current_booking_stats = {
      total: Booking.confirmed.where(created_at: month.first_day..month.last_day).count,
      paid: Booking.confirmed.paid.where(created_at: month.first_day..month.last_day).count, 
      unpaid: Booking.confirmed.unpaid.where(created_at: month.first_day..month.last_day).count
    }
    render layout: false
  end


  protected

  def new_courses_chart(month = Month.current)
    data = (month.first_day..month.last_day).map {|date| Course.on_date(date).count }
    LazyHighCharts::HighChart.new('graph') do |f|
      f.title :text => "Courses run in #{month.first_day.strftime("%B, %Y")}"
      f.xAxis type: 'datetime'
      f.series(
        :name => "", 
        :yAxis => 0, 
        :data => data,
        :pointInterval => 86400,
        :pointStart => month.first_day, 
        :yAxis => 0,
        :connectNulls => true)
      f.chart({:defaultSeriesType=>"area"})
      f.legend(  :enabled => false)
    end

  end


  def new_chalkers_chart(month = Month.current)
    data = (month.first_day..month.last_day).map {|date| Chalkler.where(created_at: date.beginning_of_day..date.end_of_day).count }
    LazyHighCharts::HighChart.new('graph') do |f|
      f.title :text => "User Signups for #{month.first_day.strftime("%B, %Y")}"
      f.xAxis type: 'datetime'
      f.series(
        :name => "Signups",
        :yAxis => 0, 
        :data => data,
        :pointInterval => 86400,
        :pointStart => month.first_day, 
        :yAxis => 0,
        :connectNulls => true)
      f.chart({:defaultSeriesType=>"area"})
      f.legend(  :enabled => false)
    end

  end

  def new_bookings_chart(month = Month.current)
    free_data = (month.first_day..month.last_day).map {|date| Booking.confirmed.unpaid.where(created_at: date.beginning_of_day..date.end_of_day).count }
    paid_data = (month.first_day..month.last_day).map {|date| Booking.confirmed.paid.where(created_at: date.beginning_of_day..date.end_of_day).count }
    all_data = (month.first_day..month.last_day).map {|date| Booking.confirmed.where(created_at: date.beginning_of_day..date.end_of_day).count }
    LazyHighCharts::HighChart.new('graph') do |f|
      f.title text: "Bookings in #{month.first_day.strftime("%B, %Y")}"
      f.xAxis  type: 'datetime'
      f.series(
        :name => "All Bookings", 
        :yAxis => 0, 
        :data => all_data,
        :pointInterval => 86400,
        :pointStart => month.first_day, 
        :yAxis => 0,
        :connectNulls => true)
      f.series(
        :name => "Free", 
        :yAxis => 0, 
        :data => free_data,
        :pointInterval => 86400,
        :pointStart => month.first_day, 
        :yAxis => 0,
        :connectNulls => true)
      f.series(
        :name => "Paid", 
        :yAxis => 0, 
        :data => paid_data,
        :pointInterval => 86400,
        :pointStart => month.first_day, 
        :yAxis => 0,
        :connectNulls => true)
      f.legend(:align => 'center', :verticalAlign => 'bottom', :y => -30, :x => 0, :layout => 'horizontal')
      f.chart({:defaultSeriesType=>"line"})
    end
  end



  def set_title
    @page_title = "Platform Metrics"
  end


end