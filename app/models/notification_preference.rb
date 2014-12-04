class NotificationPreference < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  
  attr_accessible *BASIC_ATTR = [:chalkler, :chalkler_id]
  
  belongs_to :chalkler

  #line as per https://docs.google.com/a/chalkle.com/spreadsheets/d/1ya4Jb167tRGf-oFaEATLoNWgDWwAT3i27V7iCSYwUaQ/edit#gid=0

  ##
  # => CHALKLERS
  ##

  def welcome_chalkler
    #3
    chalkler.send_notification Notification::CHALKLE, me_preferences_path, I18n.t('notify.chalkler.welcome', name: chalkler.first_name)

    ChalklerMailer.welcome(chalkler).deliver!
  end

  def chalkler_we_miss_you
    #4
    #escalates to 14
  end

  def booking_confirmation
    #5
  end

  def booking_cancelled(booking)
    refund_text = booking.pending_refund? ? t('notify.booking.refund') : ""
    chalkler.send_notification Notification::REMINDER, course_path(booking.course), I18n.t('notify.booking.cancelled', course_name: booking.course.name, refund: refund_text)

    BookingMailer.booking_cancelled(booking).deliver!
  end

  def course_details_changed
    #6
  end

  def upcoming_booking
    #7
  end

  def after_class_follow_up 
    #8
  end

  def feedback_reminder
    #9
  end

  def chalkler_course_cancelled
    #10
  end


  ##
  # => TEACHERS
  ##

  def welcome_teacher
    #11
  end

  def teaching_new_class
    #12
  end

  def low_students_teacher
    #13
  end

  def low_students_admin
    #15
  end

  def teacher_we_miss_you
    #14
    #fallback to #4
  end

  def course_full
    #16 / #18
  end

  def teacher_course_cancelled 
    #17
  end

  def upcoming_teaching
    #19
  end

  def teaching_follow_up
    #20
  end

  def teaching_feedback
    #notification received feedback
  end


  ##
  # => PROVIDER
  ##

  def welcome_provider
    #21
  end

  def provider_we_miss_you
    #22
  end

  def provider_course_cancelled
    #23
  end

  def provider_class_follow_up
    #24
  end

  def monthly_summary
    #25
  end

end