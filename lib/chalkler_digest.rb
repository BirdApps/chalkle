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
    ChalklerMailer.digest(@chalkler, new, open)
  end

  def self.load_chalklers(freq)
    Chalkler.where("email IS NOT NULL AND email_frequency = ?", freq)
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
    Lesson.visible.published.where("created_at > CURRENT_DATE - ? AND
                                   created_at <= CURRENT_DATE",
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
    Lesson.visible.published.where("start_at > CURRENT_DATE + 1 AND
                                   start_at <= CURRENT_DATE + ? AND
                                   created_at <= CURRENT_DATE - ?",
                                   @date_offset + 1, @date_offset).limit(@limit)
  end

end