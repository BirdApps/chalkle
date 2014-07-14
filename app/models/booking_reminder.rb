class BookingReminder
  def initialize(c, course_start_in)
    @chalkler = c
    @course_start_in = course_start_in
  end

  def create!
    bookings = remind_now
    if bookings.any?
      BookingMailer.pay_reminder(@chalkler, bookings).deliver!
      log_times(bookings)
    end
  end

  def self.load_chalklers
    chalklers = Booking.visible.confirmed.billable.unpaid.upcoming.select("DISTINCT chalkler_id").map{ |b| Chalkler.find(b.chalkler_id)}
    chalklers.delete_if { |c| (c.email == nil || c.email == "") }
  end

  def remindable
    bookings = @chalkler.bookings.visible.confirmed.billable.unpaid.upcoming
    bookings.delete_if { |b| (b.teacher? == true || !b.course.channel || b.course_start_at.present? == false || b.cost == 0) }
  end

  def remind_now
    if remindable.any?
      bookings = remindable.keep_if {|b| (b.course_start_at <= (Time.now.utc + @course_start_in)) & (b.course_start_at > (Time.now.utc + @course_start_in - 1.day-1.minute)) }
      return fresh_records(bookings.sort_by{|b| b[:course_start_at]}.reverse)
    else
      return []
    end
  end

  def log_times(bookings)
    bookings.each do |b|
      b.update_attributes!({:reminder_last_sent_at => Time.now.utc.to_datetime}, :as => :admin)
    end
  end

  private

  # This is a hack because the code in remind_now is performing a find that is too complex, and it returns records
  # that are readonly.
  def fresh_records(records)
    records.map do |record|
      record.class.find(record.id)
    end
  end

end
