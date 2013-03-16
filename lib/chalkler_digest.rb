class ChalklerDigest
  def self.load_chalklers(frequency)
    Chalkler.where("email IS NOT NULL AND email_frequency = ?", frequency)
  end

  def prepare_digest
  end

  def queue_digest!
  end

  def load_new_lessons
  end

  def load_open_lessons
  end

  def self.lesson_filter(chalkler,lessons)
    filtered_lessons = lessons.find(:all, :conditions => ["category_id IN (?)", chalkler.email_categories] )
    if filtered_lessons.count == 0
      if chalkler.email_frequency == "daily"
        return lessons.find(:all, :limit => 5)
      elsif chalkler.email_frequency == "weekly"
        return lessons.find(:all, :limit => 10)
      end
    else
      return filtered_lessons
    end
  end

  # Change created_at to published_at when migration on lesson table has been completed
  def filtered_new_lessons
    if self.email_frequency == "daily"
      lesson_filter(self,Lesson.where("created_at > current_date - 1 AND created_at <= current_date AND status = 'Published' AND visible = true "))
    elsif self.email_frequency == "weekly"
      lesson_filter(self,Lesson.where("created_at > current_date - 7 AND created_at <= current_date AND status = 'Published' AND visible = true "))
    end
  end

  def filtered_still_open_lessons
    if self.email_frequency == "daily"
      lesson_filter(self,Lesson.where("start_at > current_date + 1 AND start_at <= current_date + 2 AND status = 'Published' AND visible = true AND created_at <= current_date - 1"))
    elsif self.email_frequency == "weekly"
      lesson_filter(self,Lesson.where("start_at > current_date + 1 AND start_at <= current_date + 8 AND status = 'Published' AND visible = true AND created_at <= current_date - 7"))
    end
  end
end