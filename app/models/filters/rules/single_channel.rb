require_relative 'single_relation'

module Filters
  module Rules
    class SingleChannel < SingleRelation
      def apply_to(scope)
        scope.only_with_channel(relation)
      end

      private

      def relation_class
        Channel
      end
    end
  end
end