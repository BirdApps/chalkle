class Sudo::BookingsController < Sudo::BaseController
  before_filter :load_booking, only: [:show, :refund, :set_status]
  before_filter :set_title, except: [:pending_refunds,:completed_refunds]

  def index
    status = params[:status].present? ? params[:status] : 'refund_pending'
    if Booking::BOOKING_STATUSES.include?(status)
      @bookings = Booking.visible.where(status: status).by_date_desc
    else
      @bookings = Booking.visible.by_date_desc
    end
  end

  def refund
    if @booking.refund!
      flash[:notice] = "Booking #{@booking.id} has been marked as refunded"
    else
      flash[:notice] = "Booking #{@booking.id} could not be marked as refunded"
    end

    redirect_to sudo_bookings_path({status: 'refund_pending'})
  end

  def set_status
    @booking.status = params[:status] if params[:status].present?
    @booking.save
    redirect_to sudo_bookings_path(anchor: 'booking-'+@booking.id.to_s)
  end

  def show
  end

  private


    def load_booking
      @booking = Booking.find_by_id params[:id]
    end

    def set_title
      @page_title = "Bookings"
    end
end