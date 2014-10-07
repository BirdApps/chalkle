class Sudo::BookingsController < Sudo::BaseController
  before_filter :authorize_super
  before_filter :set_titles
  before_filter :load_booking, only: [:show, :refund]
  before_filter :set_title, except: [:pending_refunds,:completed_refunds]

  def index
    @bookings = Booking.by_date
  end

  def pending_refunds
    @page_title = "Pending Refunds"
    @bookings = Booking.where(status: 'refund_pending')
    render 'index'
  end

  def completed_refunds
    @page_title = "Completed Refunds"
    @bookings = Booking.where(status: 'refund_complete')
    render 'index'
  end

  def refund
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