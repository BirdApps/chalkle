# encoding: UTF-8
class BookingMailer < BaseChalkleMailer

  default from: '"chalkle°" <learn@chalkle.com>' 

  def booking_confirmation(booking)
    @booking = booking
    @chalkler = booking.chalkler
    @course = booking.course
    mail(to: @chalkler.email, subject: "#{@chalkler.name}, congrats! You are booked in to #{@course.name}") do |format| 
      format.text { render layout: 'standard_mailer' }
      format.html { render layout: 'standard_mailer' }
    end
  end


  def booking_reminder(booking)
    
    @booking = booking
    @chalkler = booking.chalkler
    @course = booking.course
    mail(to: @chalkler.email, subject: "#{@chalkler.name}, your course is coming up soon!") do |format| 
      format.text { render layout: 'standard_mailer' }
      format.html { render layout: 'standard_mailer' }
    end

  end

  def booking_completed(booking)
    @booking = booking
    @chalkler = booking.chalkler
    @course = booking.course
    mail(to: @chalkler.email, subject: "#{@chalkler.name}, we hope you enjoyed your class!") do |format| 
      format.text { render layout: 'standard_mailer' }
      format.html { render layout: 'standard_mailer' }
    end
  end

end
