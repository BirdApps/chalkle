module Querying
  class CoursesForTime
    def initialize(base_scope = Course)
      @base_scope = base_scope
    end

    def load_month_courses(month)
      {
        month => DailyRecordsHash.new(courses_for_month(month))
      }
    end

    def load_upcoming_week_courses(week, current_date = Date.today)
      @week_courses = {}
      get_current_weeks(week, current_date).each do |week|
        load_another_week_courses week
      end
      while weeks_loaded_count < 4 && no_weekly_courses?
        load_another_week
      end
      @week_courses
    end

    def load_week_courses(week)
      @week_courses = {}
      load_another_week_courses(week)
      @week_courses
    end


    private

    def load_another_week_courses(week)
      @week_courses[week] = DailyRecordsHash.new(courses_for_week(week))
    end

    def courses_for_month(month)
      visible_scope.in_month(month)
    end

    def get_current_weeks(current_week, current_date)
      result = [current_week]
      result << current_week.next if current_date.friday? || current_date.saturday? || current_date.sunday?
      result
    end

    def courses_for_week(week)
      visible_scope.upcoming_or_today.in_week(week)
    end

    def visible_scope
      @base_scope.displayable
    end

    def weeks_loaded_count
      @week_courses.keys.length
    end

    def load_another_week
      next_week = @week_courses.keys.last.next
      load_another_week_courses next_week
    end

    def no_weekly_courses?
      !@week_courses.values.map(&:empty?).include?(false)
    end

  end
end