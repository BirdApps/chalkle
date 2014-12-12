class BookingsController < ApplicationController
  include HTTParty
  before_filter :authenticate_chalkler!, except: [:lpn]
  before_filter :redirect_on_paid, :only => [:edit, :update]
  before_filter :class_available, :only => [:edit, :update, :new]
  before_filter :load_booking, :only => [:payment_callback, :show, :edit, :update, :cancel, :confirm_cancel]

  def index
    @page_subtitle = "Bookings for"
    @course = Course.find_by_id params[:course_id]
    if policy(@course).read?
      @bookings = @course.bookings.visible.order(:status) if @course.present?
    else
      @bookings = []
    end
  end

  def my_bookings
    @upcoming_bookings = current_chalkler.bookings.visible.confirmed.paid.upcoming.decorate
  end

  def new
    @channel = Course.find(params[:course_id]).channel #Find channel for hero
    @booking = Booking.new
    @booking.name = current_user.name unless @course.bookings_for(current_user).present?
    @page_subtitle = "Booking for"
    @page_title_logo = @course.course_upload_image if @course.course_upload_image.present?
  end

  def create
    @booking = Booking.new params[:booking]
    @booking.name = current_user.name unless @booking.name.present?
    @booking.chalkler = current_chalkler #unless @booking.chalkler
    @booking.apply_fees

    if policy(@booking.course).admin? && params[:remove_fees] == '1'
      @booking.remove_fees
    end

    unless current_user.bookings.confirmed.where(course_id: @booking.course.id, name: @booking.name ).empty?
      redirect_to @booking.course.path, notice: 'That attendee already has a booking for this course' and return
    end

    # this should handle invalid @bookings before doing anything
    if @booking.save
      if @booking.free?
                
        @booking.chalkler.notify.booking_confirmation(@booking)

        redirect_to @booking.course.path and return
      else
        @booking.update_attribute(:status, 'pending')
        @booking.update_attribute(:visible, false)
        wrapper = SwipeWrapper.new
        identifier = wrapper.create_tx_identifier_for(
                            booking_id: @booking.id,
                            amount: @booking.cost,
                            return_url: course_booking_payment_callback_url(@booking.course_id, @booking.id),
                            description: @booking.name)
        redirect_to "https://payment.swipehq.com/?identifier_id=#{identifier}" and return
      end
    else
      @course = Course.find(params[:course_id])
      flash[:notice] = 'Could not create booking at this time'
      render 'new'
    end
  end

  def lpn
    @booking = Booking.find_by_id params[:td_user_data]
    if @booking
      payment = @booking.payment.present? ? @booking.payment : @booking.build_payment
      payment.swipe_transaction_id = params[:transaction_id]
      payment.total = params[:amount]
      payment.swipe_name_on_card= params[:name_on_card]
      payment.swipe_customer_email = params[:customer_email]
      payment.swipe_currency = params[:currency]
      payment.swipe_identifier_id = params[:identifier_id]
      payment.swipe_token= params[:token]
      payment.date = DateTime.current
      payment.visible = true
      wrapper = SwipeWrapper.new
      verify = wrapper.verify payment.swipe_transaction_id
      if verify['data']['transaction_approved'] == "yes"   
        pay_result = payment.save
        if payment.total >= @booking.cost
          @booking.status = 'yes'
          book_result = @booking.save
        end
      end
    end
    render json: { pay: pay_result, book: book_result }
  end

  def payment_callback
    payment_successful = (params[:result] =~ /accepted/i) || (params[:result] =~ /test/i)
    if payment_successful
      @booking.status = 'pending'
      @booking.visible = true
      @booking.save
      flash[:notice] = "Payment successful. Thank you very much!"

      @booking.chalkler.notify.booking_confirmation(@booking)
      
      redirect_to course_path(params[:course_id])
    else
      flash[:alert] = "Sorry, it seems that payment was declined. Would you like to try again?"
      redirect_to new_course_booking_path(params[:course_id])
    end
  end

  def show
    redirect_to @booking.course.path
  end

  def edit
    return redirect_edit_on_paid(@booking) if @booking.paid?
    @course = @booking.course
  end

  def update
    @booking.update_attributes params[:booking]
    if @booking.save
      redirect_to booking_path @booking
    else
      @course = @booking.course
      render action: 'edit'
    end
  end

  def cancel
    @page_subtitle = "Cancel booking"
    @page_title = ('<a href="'+@booking.course.path+'">'+@booking.course.name+'</a>').html_safe
    render 'cancel'
  end

  def confirm_cancel
    authorize @booking
    @booking.cancel!(current_chalkler, params[:booking][:cancelled_reason])
    return redirect_to @booking.course.path
  end

  def class_available
    valid = true
    if params[:course_id].present?
      @course = Course.find(params[:course_id])
    elsif @booking.present?
      @course = @booking.course
    else
      return
    end
    unless policy(@course).write?(true)
      
      redirect_url = if @course.has_public_status?
        course_path(@course)
      else
        root_path
      end

      unless @course.published?
        flash.notice = "This class is no longer available."
        return redirect_to redirect_url
      end
      unless @course.start_at > DateTime.current
        flash.notice = "This class has already started, and bookings cannot be created or altered"
        return redirect_to redirect_url 
      end
      unless @course.spaces_left?
        flash.notice = "The class is full"
        return redirect_to redirect_url
      end
    end
  end

  def load_booking
    @booking = current_user.bookings.find(params[:booking_id] || params[:id]).decorate
    redirect_to not_found and return if !@booking
  end

  def redirect_on_paid
    booking = Booking.find(params[:id])
    if booking.paid?
      flash[:alert] = 'You cannot edit a paid booking'
      redirect_to booking_path booking
    end
  end

  def csv
    @course = Course.find_by_id params[:course_id]
    if policy(@course).bookings_csv?
      @bookings = @course.bookings.visible.order(:status) if @course.present?
    else
      @bookings = []
    end

    send_data Booking.csv_for(@bookings), type: :csv, filename: "bookings-for-#{@course.name.parameterize}.csv"

  end


end
