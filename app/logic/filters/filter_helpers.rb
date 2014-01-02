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
        current_chalkler ? current_chalkler.lesson_filter : existing_session_filter
      end

      def start_current_chalkler_filter
        if current_chalkler
          current_chalkler.lesson_filter || current_chalkler.create_lesson_filter
        else
          start_session_filter
        end
      end

      def start_session_filter
        existing_session_filter || create_session_filter
      end

      def existing_session_filter
        if session[:filter_id]
          Filter.find session[:filter_id]
        end
      end

      def create_session_filter
        filter = Filter.create!
        session[:filter_id] = filter.id
        filter
      end
  end
end