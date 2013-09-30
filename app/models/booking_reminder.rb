class BookingReminder
  def initialize(c, lesson_start_in)
    @chalkler = c
    @lesson_start_in = lesson_start_in
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

  private

  def remindable
    bookings = @chalkler.bookings.visible.confirmed.billable.unpaid.upcoming
    bookings.delete_if { |b| (b.teacher? == true || b.lesson.channels.any? == false || b.lesson_start_at.present? == false || b.cost == 0) }
  end

  def remind_now
    if remindable.any?
      bookings = remindable.keep_if {|b| (b.lesson_start_at <= (Time.now.utc + @lesson_start_in)) & (b.lesson_start_at > (Time.now.utc + @lesson_start_in - 1.day)) }
      return bookings.sort_by{|b| b[:lesson_start_at]}.reverse
    else
      return []
    end
  end

  def log_times(bookings)
    bookings.each do |b|
      b.update_attributes!({:reminder_last_sent_at => Time.now.utc.to_datetime}, :as => :admin)
    end
  end

end