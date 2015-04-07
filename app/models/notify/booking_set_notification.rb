class Notify::BookingSetNotification < Notify::Notifier
  
  def initialize(booking_set, role = NotificationPreference::CHALKLER)
    @booking_set = booking_set
    @role = role
  end


  def send_receipt
    #to booker
    @booking_set.payments.each do |payment|
      PaymentMailer.receipt_to_chalkler(payment).deliver!
    end
  end


  def declined
    message = I18n.t('notify.booking_set.declined', course_name: @booking_set.course.name)
    @booking_set.booker.send_notification Notification::REMINDER, declined_provider_course_bookings_path( @booking_set.course.path_params({ booking_ids: @booking_set.id }) ), message, @booking_set.course
  end



  def confirmation

    chalklers = @booking_set.bookings.collect(&:chalkler).uniq
    pseudo_chalklers = @booking_set.bookings.collect(&:pseudo_chalkler_email).uniq
    teachers = @booking_set.bookings.collect(&:course).collect(&:teacher).uniq

    # get a collection of all the chalklers
    chalkler_bookings = Hash.new {|c| @booking_set.bookings.select{|b| b.chalkler == c }  }
    chalklers.map {|c| chalkler_bookings[c] }

    # get a grouped collection of all of the pseudo chalklers (not registered yet)
    pseudo_chalkler_bookings = Hash.new {|c| @booking_set.bookings.select{|b| b.pseudo_chalkler_email == c }  }
    pseudo_chalklers.map {|c| pseudo_chalkler_bookings[c] }

    # also a grouped collection of all of the teachers
    teacher_bookings = Hash.new {|c| @booking_set.bookings.select{|b| b.course.teacher == c }  }
    teachers.map {|c| teacher_bookings[c] }


    #send confirmation to each chalkler in the booking set. One confirmation to each chalkler...
    chalkler_bookings.each do |chalkler, bookings|
      
      message = I18n.t(
        'notify.booking_set.confirmation.to_chalkler',
        course_name: bookings.map(&:course).map(&:name).flatten.join(", ") # no guarantee that all bookings are from the same course, so list all the courses. 
      )
      
      chalkler.send_notification(
        Notification::REMINDER, 
        provider_course_path(bookings.first.course.path_params), 
        message, 
        bookings
      )

      if chalkler.email_about? :booking_confirmation_to_chalkler
        BookingSetMailer.booking_confirmation_to_chalkler(bookings, chalkler).deliver!  
      end

    end

    # ... now deal with pseudo bookings
    pseudo_chalkler_bookings.each do |pseudo_chalkler_email, bookings| 
      
      message = I18n.t('notify.booking.booked_in', 
        course_name: bookings.map(&:course).map(&:name).uniq.join(", "),
        booker: bookings.map(&:booker).map(&:name).uniq.join(", ")
      )

      BookingSetMailer.booking_confirmation_to_non_chalkler(bookings, pseudo_chalkler_email).deliver!

      if bookings.map(&:invite_chalkler).include?(true)
        Chalkler.invite!( { email: pseudo_chalkler_email, 
                            name: bookings.map(&:name).uniq.join(", ")
                          }, 
                          booking.booker
                        )
      end
    end
    

    #to teachers (probably only one, but handling the case with bookings from many courses for robustness)
    teacher_bookings.each do |teacher, bookings|
      message = I18n.t('notify.booking.confirmation.to_teacher', course_name: bookings.map(&:course).map(&:name).uniq.join(", "), from_name: bookings.map(&:booker).map(&:name).uniq.join(", "))

      teacher.chalkler.send_notification(Notification::REMINDER, provider_course_path(bookings.first.course.path_params), message, bookings) if teacher.chalkler

      if teacher.chalkler.blank? || teacher.chalkler.email_about?(:booking_confirmation_to_teacher)
        BookingSetMailer.booking_confirmation_to_teacher(bookings).deliver!
      end

    end
  
  end

end