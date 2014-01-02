require_relative 'single_relation'

module Filters
  module Rules
    class SingleRegion < SingleRelation
      def apply_to(scope)
        scope.only_with_region(relation)
      end

      private

      def relation_class
        Region
      end
    end
  end
end