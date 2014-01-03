require_relative 'single_relation'

module Filters
  module Rules
    class SingleChannel < SingleRelation
      def apply_to(scope)
        scope.only_with_channel(relation)
      end

      def options
        Channel.visible.all.map do |record|
          [record.name, record.id, record == relation]
        end
      end

      def clear_name
        "All channels"
      end

      def active_name
        relation ? relation.name : clear_name
      end

      private

      def relation_class
        Channel
      end
    end
  end
end