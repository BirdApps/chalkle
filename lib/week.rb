require 'monthify'

module Weekify
  module HasWeeks
    def to_weeks
      (Week.containing(first_day))..(Week.containing(last_day))
    end
  end

  class DateRange < Range
    def first_day
      first
    end

    def last_day
      last
    end
  end

  class Week < DateRange
    WEEK_LENGTH = 7
    WDAY_START = 1

    class << self
      def containing(date)
        starting date_to_week_start(date)
      end

      def starting(start_date)
        end_date = start_date + WEEK_LENGTH - 1
        new(start_date, end_date)
      end

      private

      def date_to_week_start(date)
        date - (date.wday - WDAY_START)
      end
    end

    def succ
      self.class.starting(last_day + 1)
    end

    def <=>(other)
      first_day <=> other.first_day
    end
  end

  ::Week = Weekify::Week
end

Month.send :include, Weekify::HasWeeks