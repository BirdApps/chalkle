class BookingsController < ApplicationController
  before_filter :authenticate_chalkler!
  before_filter :redirect_on_paid, :only => [:edit, :update]
  before_filter :class_available, :only => [:edit, :update, :new]
  before_filter :load_booking, :only => [:payment_callback, :show, :edit, :update, :cancel]

  def index
    @unpaid_bookings = current_chalkler.bookings.visible.confirmed.unpaid.decorate
    @upcoming_bookings = current_chalkler.bookings.visible.confirmed.paid.upcoming.decorate
  end

  def new
    if current_chalkler.courses.where{ bookings.status.eq 'yes' }.exists? @course.id
      redirect_to @course.path
    end
    delete_any_unpaid_credit_card_booking
    @booking = Booking.new
    @page_subtitle = "Booking for"
    @page_title_logo = @course.course_upload_image if @course.course_upload_image.present?
  end

  def create
    @booking = Booking.new params[:booking]
    @booking.chalkler = current_chalkler
    @booking.enforce_terms_and_conditions = true

    # this should handle invalid @bookings before doing anything
    destroy_cancelled_booking
    binding.pry
    if @booking.save
      # if @booking.payment_method == 'credit_card'
      @booking.update_attribute(:status, 'pending')
      wrapper = SwipeWrapper.new
      identifier = wrapper.create_tx_identifier_for(booking_id: @booking.id,
                                                    amount: @booking.cost,
                                                    return_url:course_booking_payment_callback_url(@booking.course_id, @booking.id),
                                                    description: @booking.name)
      return redirect_to "https://payment.swipehq.com/?identifier_id=#{identifier}"
      # else
      #   flash[:notice] = 'Booking created!'
      #   redirect_to course_booking_path @booking.course, @booking
      # end
    else
      delete_any_unpaid_credit_card_booking
      @course = Course.find(params[:course_id]).decorate
      return render action: 'new'
    end
  end

  def payment_callback
    payment_successful = (params[:result] =~ /accepted/i) && !(params[:result] =~ /test/i)
    if payment_successful
      #should I set it to yes?
      payment = @booking.build_payment
      payment.booking = @booking
      payment.total = @booking.course.cost
      payment.reconciled = true
      payment.save
      @booking.status = 'yes'
      @booking.paid = true
      @booking.visible = true
      @booking.save
      flash[:notice] = "Payment successful. Thank you very much!"
      redirect_to = course_path(params[:course_id])
    else
      flash[:alert] = "Payment was not successful. Sorry about that. Would you like to try again?"
      redirect_to new_course_booking_url(params[:channel_id], params[:course_id], params[:booking_id])
    end
  end

  def show
  end

  def edit
    redirect_edit_on_paid(@booking) if @booking.paid?
    @course = @booking.course.decorate
  end

  def update
    @booking.update_attributes params[:booking]
    if @booking.save
      redirect_to booking_path @booking
    else
      @course = @booking.course.decorate
      render action: 'edit'
    end
  end

  def cancel
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
  def class_available
    valid = true
    if params[:course_id].present?
      @course = Course.find(params[:course_id]).decorate
    elsif @booking.present? 
      @course = @booking.course
    else
      return
    end
    unless @course.published?
      redirect_to root_url, notice: "This class is no longer available."
    end
    unless @course.start_at > DateTime.now
      redirect_to @course.path, notice: "This class has already starting, and bookings cannot be created or altered"
    end
    unless @course.spaces_left?
      redirect_to @course.path, notice: "The class is full"
    end

  end

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
    current_chalkler.bookings.where{ (course_id == my{params[:course_id]}) & (status == 'no') }.destroy_all
  end

  def delete_any_unpaid_credit_card_booking
    if booking = current_chalkler.bookings.where(course_id: params[:course_id], payment_method: 'credit_card').first
      if booking.payment.nil?
        booking.destroy
      end
    end
  end
end
