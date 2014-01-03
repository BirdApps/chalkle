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

      private

        def relation_class
          raise NotImplementedError
        end
    end
  end
end