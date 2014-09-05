require_relative 'single_relation'

module Filters
  module Rules
    class SingleCategory < SingleRelation
      def apply_to(scope)
        scope.in_category(relation)
      end


      private

      def option_scope
        relation_class.primary
      end

      def relation_class
        Category
      end
    end
  end
end