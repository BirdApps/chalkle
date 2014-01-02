module Filters
  module FilterHelpers
    private

      def apply_filter(scope)
        current_filter.apply_to(scope)
      end

      def current_filter
        current_chalkler_filter || Filters::NullFilter.new
      end

      def current_chalkler_filter
        current_chalkler.lesson_filter if current_chalkler
      end

      def start_current_chalkler_filter
        if current_chalkler
          current_chalkler.lesson_filter || current_chalkler.create_lesson_filter
        end
      end
  end
end