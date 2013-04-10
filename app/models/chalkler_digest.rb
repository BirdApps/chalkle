class ChalklerDigest
  def initialize(c)
    @chalkler = c
    @frequency = @chalkler.email_frequency
    @digest_period = (@chalkler.email_frequency == 'daily') ? 1.day : 7.days
    @date_offset = Time.now.utc - @digest_period
    @limit = (@chalkler.email_frequency == 'daily') ? 5 : 8
  end

  def create!
    new = new_lessons
    new = default_new_lessons if new.empty?
    open = open_lessons
    open = default_open_lessons if open.empty?
    # TODO move this to delayed job asap
    ChalklerMailer.digest(@chalkler, new, open).deliver! if (new.any? || open.any?)
  end

  def self.load_chalklers(freq)
    Chalkler.where{(email != "") & (email_frequency == freq)}
  end

  private

  def new_lessons
    Lesson.visible.published.joins(:categories, :channels).where("lessons.created_at > ? AND
                                                                  lessons.meetup_url IS NOT NULL AND
                                                                  lessons.do_during_class IS NOT NULL AND
                                                                  lesson_categories.category_id IN (?) AND
                                                                  channel_lessons.channel_id IN (?)",
                                                                  @date_offset, @chalkler.email_categories,
                                                                  @chalkler.channels).order("start_at").limit(@limit)
  end

  def default_new_lessons
    Lesson.visible.published.joins(:channels).where("lessons.created_at > ? AND
                                                     lessons.meetup_url IS NOT NULL AND
                                                     lessons.do_during_class IS NOT NULL AND
                                                     channel_lessons.channel_id IN (?)",
                                                     @date_offset, @chalkler.channels).order("start_at").limit(@limit)
  end

  def open_lessons
    lessons = Lesson.visible.published.joins(:categories, :channels).where("lessons.start_at >= CURRENT_DATE AND
                                                                            lessons.meetup_url IS NOT NULL AND
                                                                            lessons.do_during_class IS NOT NULL AND
                                                                            lesson_categories.category_id IN (?) AND
                                                                            channel_lessons.channel_id IN (?)",
                                                                            @chalkler.email_categories,
                                                                            @chalkler.channels).order("start_at")
    lessons.delete_if { |l| l.bookable? == false  }
    lessons.shift @limit
  end

  def default_open_lessons
    lessons = Lesson.visible.published.joins(:channels).where("lessons.start_at >= CURRENT_DATE AND
                                                               lessons.meetup_url IS NOT NULL AND
                                                               lessons.do_during_class IS NOT NULL AND
                                                               channel_lessons.channel_id IN (?)",
                                                               @chalkler.channels).order("start_at")
    lessons.delete_if { |l| l.bookable? == false  }
    lessons.shift @limit
  end

end
