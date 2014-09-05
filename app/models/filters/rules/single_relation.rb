module Filters
  module Rules
    class SingleRelation
      def initialize(rule = nil)
        deserialize(rule) if rule
      end

      attr_accessor :relation

      def deserialize(rule)
        self.relation = relation_class.find(rule.value) if rule.value
      end

      def serialize(rule)
        rule.value = relation.id if relation
      end

      def name
        self.class.name.split("::").last.underscore
      end

      def active?
        !!relation
      end

      def active_name
        relation ? relation.name : clear_name
      end

      def options
        option_scope.all.map do |record|
          [record.name, record.id, record == relation]
        end
      end

      def apply_to(scope)
        scope.in_region(relation)
      end

      def clear_name
        "All #{relation_class.name.pluralize.downcase}"
      end

      private

        def option_scope
          relation_class
        end

        def relation_class
          raise NotImplementedError
        end
    end
  end
end