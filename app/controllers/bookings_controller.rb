class BookingsController < ApplicationController
  include HTTParty
  before_filter :authenticate_chalkler!, except: [:lpn]
  before_filter :redirect_on_paid, :only => [:edit, :update]
  before_filter :class_available, :only => [:edit, :update, :new]
  before_filter :load_booking, :only => [:show, :cancel, :confirm_cancel, :take_rights, :resend_receipt]
  before_filter :load_booking_set, only: [:payment_callback, :lpn, :declined]
  before_filter :header_provider, except:  [:payment_callback, :lpn]

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
    @booking_set.bookings << Booking.new(name: current_user.name, email: current_user.email)
  end

  def create
    @course = Course.find(params[:course_id])

    unless current_chalkler.providers_following.include? @course.provider
      Subscription.create chalkler: current_chalkler, provider: @course.provider
    end

    @booking_set = BookingSet.new params[:booking_set], params[:note_to_teacher]
    waive_fees = policy(@course).admin? && params[:remove_fees] == '1'
    if @booking_set.save({ free: waive_fees, booker: current_chalkler })
      payment_pending = false
     
      @booking_set.bookings.each do |booking|
        unless booking.free?
          payment_pending = true
          booking.update_attribute(:status, 'pending')
          booking.update_attribute(:visible, false)
        end
      end

      unless payment_pending
        Notify.for(@booking_set).confirmation
        redirect_to @course.path and return
      else
        wrapper = SwipeWrapper.new
        identifier = wrapper.create_tx_identifier_for(
                            booking_set_id: @booking_set.id,
                            amount: @booking_set.cost_per_booking,
                            quantity: @booking_set.count,
                            email: current_chalkler.email,
                            return_url: payment_callback_url(@booking_set.id),
                            description: ("Booking".pluralize(@booking_set.count)+" for "+@course.name) )
        @booking_set.set_swipe_identifer!(identifier)
        redirect_to SwipeWrapper.payment_gateway(identifier) and return
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
    @course = @booking_set.course
    if payment_successful
      @booking_set.bookings.each do |booking|
        unless booking.payment.present?
          booking.status = Booking::STATUS_6
          booking.visible = true
          booking.save
        end
      end
      add_flash :success, "Payment successful. Thank you very much!"
      redirect_to provider_course_path(@course.path_params)
    else
      Notify.for(@booking_set).declined
      add_flash :error, "Sorry, it seems the payment was declined. Would you like to try again?"
      redirect_to declined_provider_course_bookings_path( @course.path_params({ booking_ids: @booking_set.id }) ) and return
    end
  end

  def declined
    if @booking_set.status != Booking::STATUS_5
      if @booking_set.status == Booking::STATUS_6
        add_flash :success, "Payment successful. Thank you very much!"
      elsif @booking_set.status == Booking::STATUS_1
        add_flash :success, "Payment confirmed. Thank you very much!"
      elsif @booking_set.status == Booking::STATUS_2
        add_flash :success, "Booking was cancelled"
      end
      redirect_to provider_course_path(@booking_set.course.path_params) and return
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
    
    opts = current_user.super? ? {as: :super} : {}

    send_data Booking.csv_for(@bookings, opts), type: :csv, filename: "bookings-for-#{@course.name.parameterize}.csv"
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

  def resend_receipt
    authorize @booking
    if @booking.payment.present?
      PaymentMailer.delay.receipt_to_chalkler(@booking.payment, true)
      add_flash :success, "Receipt has been sent to the #{@booking.payment.chalkler.email}"
    else
      add_flash :error, "No payment was made for that booking"
    end
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
          provider_course_path(@course.path_params)
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
      not_found if !@booking
    end

    def load_booking_set
      @booking_set = BookingSet.new
      if params[:td_user_data].present?
        @booking_set.ids = params[:td_user_data] 
      elsif params[:booking_ids].present?
        @booking_set.ids = params[:booking_ids] 
      end
      #TODO: check swipe_identifier to find/ensure related bookings
      not_found and return unless @booking_set.bookings.present?
    end

    def redirect_on_paid
      booking = Booking.find(params[:id])
      if booking.paid?
        add_flash :warning, 'You cannot edit a paid booking'
        redirect_to booking_path booking
      end
    end

end
