class BookingsController < ApplicationController
  before_filter :authenticate_chalkler!
  before_filter :horowhenua?, :except => [:show, :index, :cancel, :edit, :update]
  before_filter :redirect_on_paid, :only => [:edit, :update]

  def index
    @unpaid_bookings = current_chalkler.bookings.visible.confirmed.unpaid.decorate
    @upcoming_bookings = current_chalkler.bookings.visible.upcoming.confirmed.paid.order('lessons.start_at').decorate
  end

  def new
    if current_chalkler.lessons.where{ bookings.status.eq 'yes' }.exists? params[:lesson_id]
      flash[:notice] = 'You are already attending this class'
      redirect_to :back
    end
    delete_any_unpaid_credit_card_booking
    @booking = Booking.new
    @lesson = Lesson.find(params[:lesson_id]).decorate
  end

  def create
    @booking = Booking.new params[:booking]
    @booking.chalkler = current_chalkler
    @booking.enforce_terms_and_conditions = true

    # this should handle invalid @bookings before doing anything
    destroy_cancelled_booking

    if @booking.save
      if @booking.payment_method == 'credit_card'
        @booking.update_attribute(:status, 'pending')
        wrapper = SwipeWrapper.new
        identifier = wrapper.create_tx_identifier_for(booking_id: @booking.id,
                                                      amount: @booking.cost,
                                                      return_url: channel_lesson_booking_payment_callback_url(params[:channel_id], @booking.lesson_id, @booking.id),
                                                      description: @booking.name)
        redirect_to "https://payment.swipehq.com/?identifier_id=#{identifier}"
      else
        flash[:notice] = 'Booking created!'
        redirect_to booking_path @booking
      end
    else
      delete_any_unpaid_credit_card_booking
      @lesson = Lesson.find(params[:lesson_id]).decorate
      render action: 'new'
    end
  end

  def payment_callback
    load_booking
    payment_successful = (params[:result] =~ /accepted/i) && !(params[:result] =~ /test/i)
    if payment_successful
      #should I set it to yes?
      payment = @booking.build_payment
      payment.total = @booking.lesson.cost
      payment.reconciled = true
      payment.save
      @booking.status = 'yes'
      @booking.paid = true
      @booking.visible = true
      @booking.save
      flash[:notice] = "Payment successful. Thank you very much!"
      redirect_to channel_lesson_path(params[:channel_id], params[:lesson_id])
    else
      flash[:alert] = "Payment was not successful. Sorry about that. Would you like to try again?"
      redirect_to new_channel_lesson_booking_url(params[:channel_id], params[:lesson_id], params[:booking_id])
    end
  end

  def show
    load_booking
  end

  def edit
    load_booking
    redirect_edit_on_paid(@booking) if @booking.paid?
    @lesson = @booking.lesson.decorate
  end

  def update
    load_booking
    @booking.update_attributes params[:booking]
    if @booking.save
      redirect_to booking_path @booking
    else
      @lesson = @booking.lesson.decorate
      render action: 'edit'
    end
  end

  def cancel
    load_booking
    @booking.status = 'no'
    if @booking.save
      flash[:notice] = "Your booking is cancelled. Please contact accounts@chalkle.com quote booking id #{@booking.id} if you require a refund."
      redirect_to bookings_path
    else
      flash[:alert] = 'Your booking cannot be cancelled. Please contact your Channel Curator for further information'
      redirect_to :back
    end
  end

  private
  def load_booking
    @booking = current_chalkler.bookings.find(params[:booking_id] || params[:id]).decorate
  end

  def redirect_on_paid
    booking = Booking.find(params[:id])
    if booking.paid?
      flash[:alert] = 'You cannot edit a paid booking'
      redirect_to booking_path booking
    end
  end

  def destroy_cancelled_booking
    current_chalkler.bookings.where{ (lesson_id == my{params[:lesson_id]}) & (status == 'no') }.destroy_all
  end

  def delete_any_unpaid_credit_card_booking
    if booking = current_chalkler.bookings.where(lesson_id: params[:lesson_id], payment_method: 'credit_card').first
      if booking.payment.nil?
        booking.destroy
      end
    end
  end
end
