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
    # TODO move this to delayed job
    ChalklerMailer.digest(@chalkler, new, open).deliver! if (new.any? || open.any?)
  end

  def self.load_chalklers(freq)
    Chalkler.where{(email != "") & (email_frequency == freq)}
  end

  # private

  def new_lessons
    Lesson.visible.published.joins(:categories, :channels).where("lessons.published_at > ? AND
                                                                  lessons.meetup_url IS NOT NULL AND
                                                                  lessons.do_during_class IS NOT NULL AND
                                                                  lesson_categories.category_id IN (?) AND
                                                                  channel_lessons.channel_id IN (?) AND
                                                                  channels.visible IS TRUE",
                                                                  @date_offset, @chalkler.email_categories,
                                                                  @chalkler.channels).order("start_at").limit(@limit).uniq
  end

  def default_new_lessons
    Lesson.visible.published.joins(:channels).where("lessons.published_at > ? AND
                                                     lessons.meetup_url IS NOT NULL AND
                                                     lessons.do_during_class IS NOT NULL AND
                                                     channel_lessons.channel_id IN (?),
                                                     channels.visible IS TRUE",
                                                     @date_offset, @chalkler.channels).order("start_at").limit(@limit).uniq
  end

  def open_lessons
    lessons = Lesson.visible.published.joins(:categories, :channels).where("lessons.start_at > ? AND
                                                                            lessons.published_at <= ? AND
                                                                            lessons.meetup_url IS NOT NULL AND
                                                                            lessons.do_during_class IS NOT NULL AND
                                                                            lesson_categories.category_id IN (?) AND
                                                                            channel_lessons.channel_id IN (?),
                                                                            channels.visible IS TRUE",
                                                                            Time.now.utc + 1.day, @date_offset, @chalkler.email_categories,
                                                                            @chalkler.channels).order("start_at").uniq
    lessons.delete_if { |l| l.bookable? == false  }
    lessons.shift @limit
  end

  def default_open_lessons
    lessons = Lesson.visible.published.joins(:channels).where("lessons.start_at > ? AND
                                                               lessons.published_at <= ? AND
                                                               lessons.meetup_url IS NOT NULL AND
                                                               lessons.do_during_class IS NOT NULL AND
                                                               channel_lessons.channel_id IN (?),
                                                               channels.visible IS TRUE",
                                                               Time.now.utc + 1.day, @date_offset, @chalkler.channels).order("start_at").uniq
    lessons.delete_if { |l| l.bookable? == false  }
    lessons.shift @limit
  end

end
