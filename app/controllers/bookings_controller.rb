class BookingsController < ApplicationController
  include HTTParty
  before_filter :authenticate_chalkler!, except: [:lpn]
  before_filter :redirect_on_paid, :only => [:edit, :update]
  before_filter :class_available, :only => [:edit, :update, :new]
  before_filter :load_booking, :only => [:show, :cancel, :confirm_cancel, :take_rights]
  before_filter :load_booking_set, only: [:payment_callback, :lpn]
  
  def index
    @course = Course.find_by_id params[:course_id]
    if policy(@course).read?
      @bookings = @course.bookings.visible.order(:status) if @course.present?
    else
      @bookings = []
    end
  end

  def new
    @provider = Course.find(params[:course_id]).provider #Find provider for hero
    @booking_set = BookingSet.new
    @booking_set.bookings << Booking.new(name: current_user.name)
    @page_title_logo = @course.course_upload_image if @course.course_upload_image.present?
  end

  def create
    @course = Course.find(params[:course_id])
    @booking_set = BookingSet.new params[:booking_set], params[:note_to_teacher]
    waive_fees = policy(@course).admin? && params[:remove_fees] == '1'
    
    if @booking_set.save({ free: waive_fees, booker: current_chalkler })
      payment_pending = false
      @booking_set.bookings.each do |booking|
        if booking.pseudo_chalkler_email
          Notify.for(booking).booked_in
          #TODO: notify person of booking and suggest signup
          Chalkler.invite!({email: booking.pseudo_chalkler_email, name: booking.name}, booking.booker) if booking.invite_chalkler
        end

        if booking.free?
          Notify.for(booking).confirmation
        else
          payment_pending = true
          booking.update_attribute(:status, 'pending')
          booking.update_attribute(:visible, false)
        end
      end

      unless payment_pending
        redirect_to @course.path and return
      else
        wrapper = SwipeWrapper.new
        identifier = wrapper.create_tx_identifier_for(
                            booking_set_id: @booking_set.id,
                            amount: @booking_set.cost_per_booking,
                            quantity: @booking_set.count,
                            email: current_chalkler.email,
                            return_url: course_booking_payment_callback_url(@course.id, @booking_set.id),
                            description: ("Booking".pluralize(@booking_set.count)+" for "+@course.name) )
        redirect_to "https://payment.swipehq.com/?identifier_id=#{identifier}" and return
      end
    else
      @booking_set.bookings.unshift Booking.new(name: current_user.name)
      add_flash :error, @booking_set.the_errors
      render 'new'
    end
  end


  def lpn
    payment = @booking_set.build_payment
    payment.swipe_transaction_id = params[:transaction_id]
    payment.total = params[:amount]
    payment.swipe_name_on_card = params[:name_on_card]
    payment.swipe_customer_email = params[:customer_email]
    payment.swipe_currency = params[:currency]
    payment.swipe_identifier_id = params[:identifier_id]
    payment.swipe_token = params[:token]
    payment.date = DateTime.current
    payment.visible = true
    verify = SwipeWrapper.verify payment.swipe_transaction_id
    unless Rails.env.titleize == "Production" && verify['data']['status'].include?('test') 
      if verify['data']['transaction_approved'] == "yes" 
        pay_result = payment.save
        book_result = @booking_set.apply_payment payment
      end
    end
    render json: { pay: pay_result, book: book_result }
  end

  def payment_callback
    payment_successful = (params[:result] =~ /accepted/i) || (params[:result] == 'test-accepted')
    if payment_successful
      @booking_set.bookings.each do |booking|
        unless booking.payment.present?
          booking.status = 'pending'
          booking.visible = true
          booking.save
        end
      end
      add_flash :success, "Payment successful. Thank you very much!"
      redirect_to course_path(params[:course_id])
    else
      @course = Course.find params[:course_id]
      add_flash :error, "Sorry, it seems that payment was declined. Would you like to try again?"
      render 'new'
    end
  end

  def show
    redirect_to @booking.course.path
  end

  def cancel
    authorize @booking
    @page_title = "[#{@booking.course.name}](#{@booking.course.path})"
    render 'cancel'
  end

  def confirm_cancel
    authorize @booking
    if @booking.cancel!(params[:booking][:cancelled_reason])
      Notify.for(@booking).cancelled
    end
    return redirect_to @booking.course.path
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

  def edit
    #TODO: edit a booking's attendee name and email
  end

  def update
  end

  def take_rights
    authorize @booking
    @booking.chalkler = current_chalkler
    @booking.save
    #TODO: email old owner telling them what happened to their booking
    redirect_to @booking.course.path
  end

  private

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
      @booking = Booking.find(params[:booking_id] || params[:id])
      redirect_to not_found and return if !@booking
    end

    def load_booking_set
      @booking_set = BookingSet.new
      booking_ids = params[:td_user_data].present? ? params[:td_user_data].split(',') : params[:booking_id].split(',')
      @booking_set.bookings = booking_ids.map{ |id| Booking.find id }
      redirect_to not_found and return if @booking_set.count != booking_ids.count
    end

    def redirect_on_paid
      booking = Booking.find(params[:id])
      if booking.paid?
        add_flash :warning, 'You cannot edit a paid booking'
        redirect_to booking_path booking
      end
    end

end
