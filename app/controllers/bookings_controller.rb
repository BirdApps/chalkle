class BookingsController < ApplicationController
  before_filter :horowhenua?

  def new
    @booking = Booking.new
    @booking.lesson = Lesson.find(params[:lesson_id]).decorate
  end

  def create
  end
end