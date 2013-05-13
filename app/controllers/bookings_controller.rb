class BookingsController < ApplicationController
  before_filter :horowhenua?, :except => [:show]
  before_filter :authenticate_chalkler!

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
    @booking = Booking.find(params[:id]).decorate
    if @booking.chalkler.id != current_chalkler.id
      flash[:warning] = 'You are unauthorized to access this page.'
      redirect_to root_url
    end
  end
end