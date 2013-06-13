class BookingsController < ApplicationController
  before_filter :horowhenua?, :except => [:show, :index]
  before_filter :authenticate_chalkler!

  def index
    @unpaid_bookings = current_chalkler.bookings.visible.unpaid.decorate
    @upcoming_bookings = current_chalkler.bookings.visible.upcoming.paid.order('lessons.start_at').decorate
  end

  def new
    if current_chalkler.lessons.exists? params[:lesson_id]
      flash[:notice] = 'You have already attending this class'
      redirect_to :back
    end
    @booking = Booking.new
    @lesson = Lesson.find(params[:lesson_id]).decorate
  end

  def create
    @booking = Booking.new params[:booking]
    @booking.enforce_terms_and_conditions = true
    @booking.chalkler = current_chalkler
    @booking.status = 'yes'
    if @booking.save
      redirect_to booking_path @booking
    else
      @lesson = Lesson.find(params[:lesson_id]).decorate
      render action: 'new'
    end
  end

  def show
    @booking = current_chalkler.bookings.find(params[:id]).decorate
  end
end