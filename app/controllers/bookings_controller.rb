class BookingsController < ApplicationController
  before_filter :horowhenua?
  before_filter :authenticate_chalkler!

  def new
    @booking = Booking.new
    @lesson = Lesson.find(params[:lesson_id]).decorate
  end

  def create
    @booking = Booking.new params[:booking]
    @booking.chalkler = current_chalkler
    @booking.status = 'yes'
    if @booking.save
      redirect_to action: 'show'
    else
      @lesson = Lesson.find(params[:lesson_id]).decorate
      render action: 'new'
    end
  end

  def show
    @booking = Booking.find params[:booking_id]
  end
end