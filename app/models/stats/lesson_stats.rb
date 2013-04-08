class Lesson_stats
  include ActiveAttr::Model

  attr_accessor :start, :period, :channel

  validates_date :start, :allow_nil => false, :on_or_after => '2012-08-01'
  validates_date :period, :allow_nil => false, :on_after_after => 1.day
  validates :channel, :presence => { :message => "Must have a channel to calculate statistics on"}

  def initialize(start, period, channel)
    @start = start
    @period = period
    @channel = channel
  end

  def lessons_ran
    channel.lesson_ran(start,end_time).count
  end

  def new_lessons_ran
    new_lesson(channel.lesson_ran(start,end_time))
  end

  def cancelled_lessons
    channel.cancel_lessons(start,end_time).count
  end

  def new_cancelled_lessons
    new_lesson(channel.cancel_lessons(start,end_time))
  end

  def paid_lessons
    channel.paid_lessons(start,end_time).count
  end

  def attendee
    l = channel.lesson_ran(start,end_time)
    total = 0
    l.each do |lesson|
      total = total + lesson.attendance
    end
    return total
  end

  def fill_fraction
    l = channel.lesson_ran(start,end_time)
    total = 0
    l.each do |lesson|
      if lesson.attendance > 0
        total = total + lesson.attendance.to_d / (lesson.max_attendee.present? ? lesson.max_attendee.to_d : lesson.attendance.to_d)
      end
    end
    if l.length > 0
      return total / l.length*100
    else
      return 0
    end
  end

  private
  def end_time
    start + period
  end

  def new_lesson(lessons)
    new_lesson = 0
    l_old = channel.past_lessons(start)
    lessons.each do |lesson|
    if l_old.find_by_name(lesson.name).nil?
      new_lesson = new_lesson + 1
    end
    end
    return new_lesson
  end

end
