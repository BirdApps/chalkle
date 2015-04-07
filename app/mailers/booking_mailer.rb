# encoding: UTF-8
class BookingMailer < BaseChalkleMailer

  default from: '"chalkle°" <learn@chalkle.com>' 


  def booking_cancelled_to_chalkler(booking)
    @booking = booking
    @chalkler = booking.chalkler
    @course = booking.course
    @mail_header_color = @booking.provider.header_color(:hex)
    mail(to: @chalkler.email, subject: I18n.t("email.booking.cancelled.to_chalkler.subject", name: @chalkler.name)) do |format| 
      format.text { render layout: 'standard_mailer' }
      format.html { render layout: 'standard_mailer' }
    end
  end

  def booking_cancelled_to_teacher(booking)
    @booking = booking
    @teacher = booking.teacher
    @course = booking.course
    @mail_header_color = @booking.provider.header_color(:hex)
    mail(to: @teacher.email, subject: I18n.t("email.booking.cancelled.to_teacher.subject", course_name: @course.name)) do |format| 
      format.text { render layout: 'standard_mailer' }
      format.html { render layout: 'standard_mailer' }
    end
  end

  def booking_cancelled_to_provider_admin(booking, provider_admin)
    @booking = booking
    @teacher = booking.teacher
    @course = booking.course
    @provider_admin = provider_admin
    @mail_header_color = @booking.provider.header_color(:hex)
    mail(to: @provider_admin.email, subject: I18n.t("email.booking.cancelled.to_provider_admin.subject", course_name: @course.name)) do |format| 
      format.html { render layout: 'standard_mailer' }
    end
  end


  def booking_reminder(booking)
    @booking = booking
    @chalkler = booking.chalkler
    @course = booking.course
    @mail_header_color = @booking.provider.header_color(:hex)
    mail(to: @chalkler.email, subject: I18n.t("email.booking.reminder.subject", name: @chalkler.first_name)) do |format| 
      format.text { render layout: 'standard_mailer' }
      format.html { render layout: 'standard_mailer' }
    end
  end

  def booking_completed(booking)
    @booking = booking
    @chalkler = booking.chalkler
    @course = booking.course
    @mail_header_color = @booking.provider.header_color(:hex)
    mail(to: @chalkler.email, subject: I18n.t("email.booking.completed.subject", name: @chalkler.first_name)) do |format| 
      format.text { render layout: 'standard_mailer' }
      format.html { render layout: 'standard_mailer' }
    end
  end

end




class BookingSetMailer < BaseChalkleMailer
  default from: '"chalkle°" <learn@chalkle.com>' 

  def booking_confirmation_to_chalkler(bookings, chalkler)
    @bookings = bookings
    @chalkler = chalkler
    @courses = bookings.map(&:course)
    @mail_header_color = @bookings.first.provider.header_color(:hex)
    mail(to: @chalkler.email,  subject: I18n.t("email.booking.confirmation.to_chalkler.subject"), name: @chalkler.first_name, course_name: @courses.map(&:name).join(', ')) do |format| 
      format.text { render layout: 'standard_mailer' }
      format.html { render layout: 'standard_mailer' }
    end
  end

  #for non chalklers
  def booking_confirmation_to_non_chalkler(bookings, pseudo_chalkler_email)
    @bookings = bookings
    @booker = bookings.first.booker
    @courses = bookings.map(&:course)
    @mail_header_color = @bookings.first.provider.header_color(:hex)
    mail(to: pseudo_chalkler_email,  subject: I18n.t("email.booking.confirmation.to_non_chalkler.subject"), name: pseudo_chalkler_email, course_name: @courses.map(&:name).join(', ')) do |format| 
      format.text { render layout: 'standard_mailer' }
      format.html { render layout: 'standard_mailer' }
    end
  end

  def booking_confirmation_to_teacher(bookings)
    @bookings = bookings
    @teacher = bookings.first.teacher
    @courses = bookings.map &:course
    @mail_header_color = @bookings.first.provider.header_color(:hex)
    mail(to: @teacher.email,  subject: I18n.t("email.booking.confirmation.to_teacher.subject"), course_name: @courses.map(&:name).uniq.join(", ")) do |format| 
      format.text { render layout: 'standard_mailer' }
      format.html { render layout: 'standard_mailer' }
    end
  end


end