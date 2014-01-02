require_relative 'single_relation'

module Filters
  module Rules
    class SingleRegion < SingleRelation
      def apply_to(scope)
        scope.only_with_region(relation)
      end

      def options
        Region.all.map do |region|
          [region.name, region.id, region == relation]
        end
      end

      def clear_name
        "All regions"
      end

      def active_name
        relation ? relation.name : clear_name
      end

      private

      def relation_class
        Region
      end
    end
  end
end