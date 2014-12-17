# encoding: UTF-8
class BookingMailer < BaseChalkleMailer

  default from: '"chalkle°" <learn@chalkle.com>' 

  def booking_confirmation_to_chalkler(booking)
    @booking = booking
    @chalkler = booking.chalkler
    @course = booking.course
    mail(to: @chalkler.email,  subject: I18n.t("email.booking.confirmation.to_chalkler.subject", name: @chalkler.first_name, course_name: @course.name)) do |format| 
      format.text { render layout: 'standard_mailer' }
      format.html { render layout: 'standard_mailer' }
    end
  end

  def booking_confirmation_to_teacher(booking)
    @booking = booking
    @chalkler = booking.chalkler
    @course = booking.course
    mail(to: @chalkler.email,  subject: I18n.t("email.booking.confirmation.to_teacher.subject", name: @chalkler.first_name, course_name: @course.name)) do |format| 
      format.text { render layout: 'standard_mailer' }
      format.html { render layout: 'standard_mailer' }
    end
  end

  def booking_cancelled_to_chalkler(booking)
    @booking = booking
    @chalkler = booking.chalkler
    @course = booking.course
    mail(to: @chalkler.email, subject: I18n.t("email.booking.cancelled.to_chalkler.subject", name: @chalkler.first_name)) do |format| 
      format.text { render layout: 'standard_mailer' }
      format.html { render layout: 'standard_mailer' }
    end
  end

  def booking_cancelled_to_teacher(booking)
    @booking = booking
    @chalkler = booking.chalkler
    @course = booking.course
    mail(to: @chalkler.email, subject: I18n.t("email.booking.cancelled.to_teacher.subject", name: @chalkler.first_name)) do |format| 
      format.text { render layout: 'standard_mailer' }
      format.html { render layout: 'standard_mailer' }
    end
  end

  def booking_reminder(booking)
    @booking = booking
    @chalkler = booking.chalkler
    @course = booking.course
    mail(to: @chalkler.email, subject: I18n.t("email.booking.reminder.subject", name: @chalkler.first_name)) do |format| 
      format.text { render layout: 'standard_mailer' }
      format.html { render layout: 'standard_mailer' }
    end
  end

  def booking_completed(booking)
    @booking = booking
    @chalkler = booking.chalkler
    @course = booking.course
    mail(to: @chalkler.email, subject: I18n.t("email.booking.completed.subject", name: @chalkler.first_name)) do |format| 
      format.text { render layout: 'standard_mailer' }
      format.html { render layout: 'standard_mailer' }
    end
  end

end
