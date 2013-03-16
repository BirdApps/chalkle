class ChalklerDigest
  def initialize(c)
    @chalkler = c
    @frequency = c.email_frequency
    @date_offset = (c.email_frequency == 'daily') ? 1 : 7
    @limit = (c.email_frequency == 'daily') ? 5 : 10
  end

  def create!
    new = new_lessons
    new = default_new_lessons if new.empty?
    open = open_lessons
    open = default_open_lessons if open.empty?
    ChalklerMailer.delay.digest(@chalkler, new, open)
  end

  def self.load_chalklers(frequency)
    Chalkler.where("email IS NOT NULL AND email_frequency = ?", frequency)
  end

  private

  def new_lessons
    Lesson.joins(:categories).where("lessons.created_at > CURRENT_DATE - ? AND
                                    lessons.created_at <= CURRENT_DATE AND
                                    lessons.status = 'Published' AND
                                    lessons.visible = true AND
                                    lesson_categories.category_id IN (?)",
                                    @date_offset, @chalkler.email_categories)
  end

  def default_new_lessons
    date_offset = (@frequency == 'daily') ? 1 : 7
    Lesson.where("created_at > CURRENT_DATE - ? AND
                 created_at <= CURRENT_DATE AND
                 status = 'Published' AND
                 visible = true",
                 @date_offset).limit(@limit)
  end

  def open_lessons
    Lesson.joins(:categories).where("lessons.start_at > CURRENT_DATE + 1 AND
                                    lessons.start_at <= CURRENT_DATE + ? AND
                                    lessons.created_at <= CURRENT_DATE - ? AND
                                    lessons.status = 'Published' AND
                                    lessons.visible = true AND
                                    lesson_categories.category_id IN (?)",
                                    @date_offset + 1, @date_offset, @chalkler.email_categories)
  end

  def default_open_lessons
    Lesson.joins(:categories).where("lessons.start_at > CURRENT_DATE + 1 AND
                                    lessons.start_at <= CURRENT_DATE + ? AND
                                    lessons.created_at <= CURRENT_DATE - ? AND
                                    lessons.status = 'Published' AND
                                    lessons.visible = true",
                                    @date_offset + 1, @date_offset).limit(@limit)
  end

end