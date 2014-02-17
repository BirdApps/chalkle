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

  def new_lessons
    scope = base_scope.where(
      "lessons.published_at > ? AND
       lessons.do_during_class IS NOT NULL AND
       channels.visible=true",
      @date_offset)
    scope = scope_lessons_by_categories(scope)
    scope = scope_lessons_by_channels(scope)
    scope.limit(@limit).uniq
  end

  def default_new_lessons
    scope = base_scope.where(
      "lessons.published_at > ? AND
       lessons.do_during_class IS NOT NULL AND
       channels.visible=true",
       @date_offset)
    scope = scope.limit(@limit)
    scope = scope_lessons_by_channels(scope)
    scope.uniq
  end

  def open_lessons
    scope = base_scope.where(
      "lessons.start_at > ? AND
       lessons.published_at <= ? AND
       lessons.do_during_class IS NOT NULL AND
       channels.visible=true",
      Time.now.utc + 1.day, @date_offset)
    scope = scope_lessons_by_categories(scope)
    scope = scope_lessons_by_channels(scope)

    lessons = scope.uniq
    filter_out_bookable(lessons)
    lessons.shift @limit
  end

  def default_open_lessons
    scope = base_scope.where(
      "lessons.start_at > ? AND
       lessons.published_at <= ? AND
       lessons.do_during_class IS NOT NULL AND
       channels.visible=true",
      Time.now.utc + 1.day, @date_offset)
    scope = scope_lessons_by_channels(scope)
    lessons = scope.uniq
    filter_out_bookable(lessons)
    lessons.shift @limit
  end

  private

    def base_scope
      Lesson.visible.published.joins(:channel).order("start_at")
    end

    def scope_lessons_by_categories(scope)
      if @chalkler.email_categories
        return scope.where(["lessons.category_id IN (?)", @chalkler.email_categories])
      end
      scope
    end

    def scope_lessons_by_channels(scope)
      if @chalkler.channels.present?
        return scope.where("lessons.channel_id IN (?)", @chalkler.channels)
      end
      scope
    end

    def filter_out_bookable(lessons)
      lessons.delete_if { |l| l.bookable? == false  }
    end

end
