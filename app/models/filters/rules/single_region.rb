require_relative 'single_relation'

module Filters
  module Rules
    class SingleRegion < SingleRelation
      private

      def relation_class
        Region
      end
    end
  end
end