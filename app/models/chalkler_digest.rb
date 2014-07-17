class ChalklerDigest
  def initialize(c)
    @chalkler = c
    @frequency = @chalkler.email_frequency
    @digest_period = (@chalkler.email_frequency == 'daily') ? 1.day : 7.days
    @date_offset = Time.now.utc - @digest_period
    @limit = (@chalkler.email_frequency == 'daily') ? 5 : 8
  end

  def create!
    new = new_courses
    new = default_new_courses if new.empty?
    open = open_courses
    open = default_open_courses if open.empty?
    # TODO move this to delayed job
    ChalklerMailer.digest(@chalkler, new, open).deliver! if (new.any? || open.any?)
  end

  def self.load_chalklers(freq)
    Chalkler.where{(email != "") & (email_frequency == freq)}
  end

  def new_courses
    #binding.pry
    scope = base_scope.where("courses.published_at > ? AND courses.do_during_class IS NOT NULL AND channels.visible=true", @date_offset)
    scope = scope_courses_by_categories(scope)
    scope = scope_courses_by_regions(scope)
    scope = scope_courses_by_channels(scope)
    scope.limit(@limit).uniq
  end

  def default_new_courses
    scope = base_scope.where(
      "courses.published_at > ? AND
       courses.do_during_class IS NOT NULL AND
       channels.visible=true",
       @date_offset)
    scope = scope.limit(@limit)
    scope = scope_courses_by_channels(scope)
    scope = scope_courses_by_regions(scope)
    scope.uniq
  end

  def open_courses
    scope = base_scope.joins(:lessons).where(
      "lessons.start_at > ? AND
       courses.published_at <= ? AND
       courses.do_during_class IS NOT NULL AND
       channels.visible=true",
      Time.now.utc + 1.day, @date_offset)
    scope = scope_courses_by_categories(scope)
    scope = scope_courses_by_channels(scope)
    scope = scope_courses_by_regions(scope)

    courses = scope.uniq
    filter_out_bookable(courses)
    courses.shift @limit
  end

  def default_open_courses
    scope = base_scope.joins(:lessons).where(
      "lessons.start_at > ? AND
       courses.published_at <= ? AND
       courses.do_during_class IS NOT NULL AND
       channels.visible=true",
      Time.now.utc + 1.day, @date_offset)
    scope = scope_courses_by_channels(scope)
    scope = scope_courses_by_regions(scope)
    courses = scope.uniq
    filter_out_bookable(courses)
    courses.shift @limit
  end

  private

    def base_scope
      Course.visible.published.joins(:channel)
    end

    def scope_courses_by_categories(scope)
      if @chalkler.email_categories
        return scope.where(["courses.category_id IN (?)", @chalkler.email_categories])
      end
      scope
    end

    def scope_courses_by_regions(scope)
      if @chalkler.email_region_ids
        return scope.where(["courses.region_id IN (?)", @chalkler.email_region_ids])
      end
      scope
    end

    def scope_courses_by_channels(scope)
      if @chalkler.channels.present?
        return scope.where("courses.channel_id IN (?)", @chalkler.channels)
      end
      scope
    end

    def filter_out_bookable(courses)
      courses.delete_if { |l| l.bookable? == false  }
    end

end
