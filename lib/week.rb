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
      self.class.starting(first_day - 7)
    end

    def next
      succ
    end

    def <=>(other)
      first_day <=> other.first_day
    end

    def date_range
      self
    end
  end

  ::Week = Weekify::Week
end

Month.send :include, Weekify::HasWeeks