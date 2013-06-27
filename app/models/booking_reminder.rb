class BookingReminder
  def initialize(c, lesson_start_in)
    @chalkler = c
    @lesson_start_in = lesson_start_in
  end

  def create!
    bookings = remind_now
    BookingMailer.pay_reminder(@chalkler, bookings).deliver! if bookings.any?
  end

  def self.load_chalklers
    chalklers = Booking.visible.confirmed.billable.unpaid.upcoming.select("DISTINCT chalkler_id").map{ |b| Chalkler.find(b.chalkler_id)}
    chalklers.delete_if { |c| (c.email == nil || c.email == "") }
  end

  def remindable
    bookings = @chalkler.bookings.visible.confirmed.billable.unpaid.upcoming
    bookings.delete_if { |b| (b.teacher? == true || b.lesson.channels.any? == false || b.lesson_start_at.present? == false) }
  end

  def remind_now
    if remindable.any?
      bookings = remindable.keep_if {|b| (b.lesson_start_at <= (Time.now.utc + @lesson_start_in)) & (b.lesson_start_at > (Time.now.utc + @lesson_start_in - 1.day)) }
      return bookings.sort_by{|b| b[:lesson_start_at]}
    else
      return []
    end
  end

end
