class BookingsController < ApplicationController
  before_filter :horowhenua?, :except => [:show, :index, :cancel, :edit, :update]
  before_filter :authenticate_chalkler!

  def index
    @unpaid_bookings = current_chalkler.bookings.visible.confirmed.unpaid.decorate
    @upcoming_bookings = current_chalkler.bookings.visible.upcoming.confirmed.paid.order('lessons.start_at').decorate
  end

  def new
    if current_chalkler.lessons.exists? params[:lesson_id]
      flash[:notice] = 'You are already attending this class'
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

  def edit
    @booking = Booking.find(params[:id]).decorate
    @lesson = @booking.lesson.decorate
  end

  def update
    @booking = Booking.new params[:booking]
    if @booking.save
      redirect_to booking_path @booking
    else
      @lesson = @booking.lesson.decorate
      render action: 'edit'
    end
  end

  def cancel
    @booking = current_chalkler.bookings.find(params[:id])
    @booking.status = 'no'
    if @booking.save
      flash[:notice] = 'Your booking is cancelled'
      redirect_to bookings_path
    else
      flash[:alert] = 'Your booking cannot be cancelled. Please contact your Channel Curator for further information'
      redirect_to :back
    end
  end
end