class ChalklerDigest
  def initialize(c)
    @chalkler = c
    @frequency = @chalkler.email_frequency
    @date_offset = (@chalkler.email_frequency == 'daily') ? 1 : 7
    @limit = (@chalkler.email_frequency == 'daily') ? 5 : 10
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
    Chalkler.where("email IS NOT NULL AND email_frequency = ?", freq)
  end

  private

  def new_lessons
    Lesson.visible.published.joins(:categories, :channels).where("lessons.created_at > CURRENT_DATE - ? AND
                                                                  lessons.meetup_url IS NOT NULL AND
                                                                  lessons.do_during_class IS NOT NULL AND
                                                                  lesson_categories.category_id IN (?) AND
                                                                  channel_lessons.channel_id IN (?)",
                                                                  @date_offset, @chalkler.email_categories,
                                                                  @chalkler.channels).limit(@limit)
  end

  def default_new_lessons
    Lesson.visible.published.joins(:channels).where("lessons.created_at > CURRENT_DATE - ? AND
                                                     lessons.meetup_url IS NOT NULL AND
                                                     lessons.do_during_class IS NOT NULL AND
                                                     channel_lessons.channel_id IN (?)",
                                                     @date_offset, @chalkler.channels).limit(@limit)
  end

  def open_lessons
    lessons = Lesson.visible.published.joins(:categories, :channels).where("lessons.start_at >= CURRENT_DATE AND
                                                                            lessons.meetup_url IS NOT NULL AND
                                                                            lessons.do_during_class IS NOT NULL AND
                                                                            lesson_categories.category_id IN (?) AND
                                                                            channel_lessons.channel_id IN (?)",
                                                                            @chalkler.email_categories,
                                                                            @chalkler.channels).limit(@limit)
    lessons.delete_if { |l| l.bookable? == false  }
    lessons
  end

  def default_open_lessons
    lessons = Lesson.visible.published.joins(:channels).where("lessons.start_at >= CURRENT_DATE AND
                                                     lessons.meetup_url IS NOT NULL AND
                                                     lessons.do_during_class IS NOT NULL AND
                                                     channel_lessons.channel_id IN (?)",
                                                     @chalkler.channels).limit(@limit)
    lessons.delete_if { |l| l.bookable? == false  }
    lessons
  end

end
