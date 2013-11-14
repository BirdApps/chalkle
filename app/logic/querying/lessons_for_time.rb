module Querying
  class LessonsForTime
    def initialize(base_scope = Lesson)
      @base_scope = base_scope
    end

    def load_month_lessons(month)
      {
        month => group_by_day(lessons_for_month(month))
      }
    end

    def load_upcoming_week_lessons(week, current_date = Date.today)
      @week_lessons = {}
      get_current_weeks(week, current_date).each do |week|
        load_another_week_lessons week
      end
      while weeks_loaded_count < 4 && no_weekly_lessons?
        load_another_week
      end
      @week_lessons
    end

    def load_week_lessons(week)
      @week_lessons = {}
      load_another_week_lessons(week)
      @week_lessons
    end


    private

    def load_another_week_lessons(week)
      @week_lessons[week] = group_by_day lessons_for_week(week)
    end

    def group_by_day(lessons)
      result = {}
      lessons.each do |lesson|
        date = lesson.start_at.to_date
        result[date] ||= []
        result[date] << lesson
      end
      result
    end

    def lessons_for_month(month)
      visible_scope.in_month(month)
    end

    def get_current_weeks(current_week, current_date)
      result = [current_week]
      result << current_week.next if current_date.friday? || current_date.saturday? || current_date.sunday?
      result
    end

    def lessons_for_week(week)
      visible_scope.upcoming_or_today.in_week(week)
    end

    def visible_scope
      @base_scope.displayable
    end

    def weeks_loaded_count
      @week_lessons.keys.length
    end

    def load_another_week
      next_week = @week_lessons.keys.last.next
      load_another_week_lessons next_week
    end

    def no_weekly_lessons?
      !@week_lessons.values.map(&:empty?).include?(false)
    end

  end
end