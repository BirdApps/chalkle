require 'monthify'

module Weekify
  module HasWeeks
    def to_weeks
      (Week.containing(first_day))..(Week.containing(last_day))
    end

    def name
      first_day.strftime('%B')
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
    LENGTH = 7

    class << self
      def containing(date)
        starting date.beginning_of_week
      end

      def starting(start_date)
        new(start_date, start_date.end_of_week)
      end

      def on_weekend?(date)
        date.saturday? || date.sunday?
      end

      def current
        containing(Date.today)
      end
    end

    def succ
      self.class.starting(last_day + 1)
    end

    def previous
      self.class.starting(first_day - LENGTH)
    end

    def next
      succ
    end

    def <=>(other)
      first_day <=> other.first_day
    end

    def +(number)
      return self if number == 0
      self.class.starting(first_day + (LENGTH * number))
    end

    def date_range
      self
    end

    def time_range
      Range.new(first_moment, last_moment)
    end

    #@return [Time] the very beginning of the month
    def first_moment
      first_day.beginning_of_day
    end

    #@return [Time] the very end of the month
    def last_moment
      last_day.end_of_day
    end

    %w(monday tuesday wednesday thursday friday saturday sunday).each_with_index do |day_name, index|
      define_method(day_name) do
        first_day + index
      end
    end
  end

  ::Week = Weekify::Week
end

Month.send :include, Weekify::HasWeeks