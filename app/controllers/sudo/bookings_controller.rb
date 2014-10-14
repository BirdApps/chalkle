class Sudo::BookingsController < Sudo::BaseController
  before_filter :authorize_super
  before_filter :set_titles
  before_filter :load_booking, only: [:show, :refund, :set_status]
  before_filter :set_title, except: [:pending_refunds,:completed_refunds]

  def index
    @bookings = Booking.by_date_desc.limit(100)
    bookings_chart_with @bookings
  end

  def pending_refunds
    @page_title = "Pending Refunds"
    @bookings = Booking.where(status: 'refund_pending')
    bookings_chart_with @bookings

    render 'index'
  end

  def completed_refunds
    @page_title = "Completed Refunds"
    @bookings = Booking.where(status: 'refund_complete')
    bookings_chart_with @bookings

    render 'index'
  end

  def refund
    if @booking.refund!
      flash[:notice] = "Booking #{@booking.id} has been marked as refunded"
    else
      flash[:notice] = "Booking #{@booking.id} could not be marked as refunded"
    end

    redirect_to pending_refunds_sudo_bookings_path
  end

  def set_status
    @booking.status = params[:status] if params[:status].present?
    @booking.save
    redirect_to sudo_bookings_path(anchor: 'booking-'+@booking.id.to_s)
  end

  def show
  end

  private

  def bookings_chart_with(bookings)
    @bookings_chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(:text => "Weekly Bookings")
      f.xAxis(:categories => Array.new(30) {|i| d = i.weeks.ago.to_date; "#{d.day}/#{d.month}" }.reverse )
      f.series(:name => "Bookings", :yAxis => 0, :data => Array.new(30) {|i|
        bookings.select{|b| b.created_at > (i+1).weeks.ago && b.created_at < i.weeks.ago }.count
      }.reverse )

      f.chart({:defaultSeriesType=>"area"})
    end
  end



    def load_booking
      @booking = Booking.find_by_id params[:id]
    end

    def set_title
      @page_title = "Bookings"
    end
end