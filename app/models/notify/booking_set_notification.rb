class Notify::BookingSetNotification < Notify::Notifier
  
  def initialize(booking_set, role = NotificationPreference::CHALKLER)
    @booking_set = booking_set
    @role = role
  end


  def send_receipt
    #to booker
    @booking_set.payments.uniq.compact.each do |payment|
      PaymentMailer.delay.receipt_to_chalkler(payment)
    end
  end


  def declined
    @booking_set.booker.send_notification(Notification::REMINDER, 
      declined_provider_course_bookings_path(@booking_set.course.path_params({ booking_ids: @booking_set.id })),
        I18n.t('notify.booking_set.declined', course_name: @booking_set.course.name), 
        @booking_set.course
      )
  end

  def confirmation
    #send confirmation to each chalkler in the booking set. One confirmation to each chalkler...
    chalkler_bookings.each do |chalkler, bookings|
      
      message = I18n.t(
        'notify.booking_set.confirmation.to_chalkler',
        course_names: bookings.map(&:course).map(&:name).uniq.flatten.join(", ") # no guarantee that all bookings are from the same course, so list all the courses. 
      )
      
      chalkler.send_notification(
        Notification::REMINDER, 
        provider_course_path(bookings.first.course.path_params), 
        message, 
        @booking_set.course
      )

      if chalkler.email_about? :booking_confirmation_to_chalkler
        BookingSetMailer.delay.booking_confirmation_to_chalkler(bookings, chalkler)  
      end

    end

    # ... now deal with pseudo bookings
    pseudo_chalkler_bookings.each do |pseudo_chalkler_email, bookings| 
      
      message = I18n.t('notify.booking_set.booked_in', 
        course_names: bookings.map(&:course).map(&:name).uniq.join(", "),
        bookers: bookings.map(&:booker).map(&:name).uniq.join(", ")
      )

      BookingSetMailer.delay.booking_confirmation_to_non_chalkler(bookings, pseudo_chalkler_email)

      if bookings.map(&:invite_chalkler).include?(true)
        Chalkler.invite!( { email: pseudo_chalkler_email, 
                            name: bookings.map(&:name).uniq.join(", ")
                          }, 
          @booking_set.booker
        )
      end
    end
    
    # to provider_teachers
    teacher_bookings.each do |teacher, bookings|
      message = I18n.t('notify.booking_set.confirmation.to_teacher', 
        course_names: bookings.map(&:course).map(&:name).uniq.join(", "), 
        from_names: bookings.map(&:booker).map(&:name).uniq.join(", ")
      )
      
      teacher.send_notification(Notification::REMINDER, provider_course_path(bookings.first.course.path_params), message, @booking_set.course)

      BookingSetMailer.delay.booking_confirmation_to_teacher(bookings) if teacher.email_about? :booking_confirmation_to_teacher

    end

  
    #to provider_admins. There can be many providers, and many admins per provider. 
    provider_bookings.each do |provider, bookings|
      message = I18n.t('notify.booking_set.confirmation.to_provider_admin', 
        course_names: bookings.map(&:course).map(&:name).uniq.join(", "), 
        from_names: bookings.map(&:booker).map(&:name).uniq.join(", ")
      )
      provider.provider_admins.map(&:chalkler).compact.each do |provider_admin|
        provider_admin.send_notification(Notification::REMINDER, provider_course_path(bookings.first.course.path_params), message, @booking_set.course)

        BookingSetMailer.delay.booking_confirmation_to_provider_admin(bookings, provider_admin) if provider_admin.email_about? :booking_confirmation_to_provider

      end
    end
  end

  private

    # get a collection of all the chalklers
    def chalkler_bookings
      h = Hash.new {|h, c| h[c] = @booking_set.bookings.select{|b| b.chalkler == c }  }
      @booking_set.bookings.collect(&:chalkler).uniq.compact.map {|c| h[c] }
      h
    end

    # get a grouped collection of all of the pseudo chalklers (not registered yet)
    def pseudo_chalkler_bookings
      
      h = Hash.new {|h, c| h[c] = @booking_set.bookings.select{|b| b.pseudo_chalkler_email == c }  }
      @booking_set.bookings.collect(&:pseudo_chalkler_email).uniq.compact.map {|c| h[c] }
      h
    end


    # also a grouped collection of all of the teachers
    def teacher_bookings
      h = Hash.new {|h, c| h[c] = @booking_set.bookings.select{|b| b.course.teacher == c }  }
      @booking_set.bookings.collect(&:course).collect(&:teacher).uniq.compact.map {|c| h[c] }
      h
    end

    def provider_bookings
    # also a grouped collection of all of the providers & bookings
      h = Hash.new {|h, c| h[c] = @booking_set.bookings.select{|b| b.course.provider == c }  }
      @booking_set.bookings.collect(&:course).collect(&:provider).uniq.compact.map {|p| h[p] }
      h
    end

end