# encoding: UTF-8
class BookingMailer < BaseChalkleMailer

  default from: '"chalkle°" <learn@chalkle.com>' 

  def booking_confirmation(booking)
    @booking = booking
    @chalkler = booking.chalkler
    @course = booking.course
    mail(to: @chalkler.email,  subject: I18n.t("email.chalkler.booking.confirmation.subject", name: @chalkler.first_name, course_name: @course.name)) do |format| 
      format.text { render layout: 'standard_mailer' }
      format.html { render layout: 'standard_mailer' }
    end
  end

  def booking_cancelled(booking)
    @booking = booking
    @chalkler = booking.chalkler
    @course = booking.course
    mail(to: @chalkler.email, subject: I18n.t("email.chalkler.booking.cancelled.subject", name: @chalkler.first_name)) do |format| 
      format.text { render layout: 'standard_mailer' }
      format.html { render layout: 'standard_mailer' }
    end
  end

  def booking_reminder(booking)
    @booking = booking
    @chalkler = booking.chalkler
    @course = booking.course
    mail(to: @chalkler.email, subject: I18n.t("email.chalkler.booking.reminder.subject", name: @chalkler.first_name)) do |format| 
      format.text { render layout: 'standard_mailer' }
      format.html { render layout: 'standard_mailer' }
    end
  end

  def booking_completed(booking)
    @booking = booking
    @chalkler = booking.chalkler
    @course = booking.course
    mail(to: @chalkler.email, subject: I18n.t("email.chalkler.booking.completed.subject", name: @chalkler.first_name)) do |format| 
      format.text { render layout: 'standard_mailer' }
      format.html { render layout: 'standard_mailer' }
    end
  end

end
