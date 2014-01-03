require_relative 'single_relation'

module Filters
  module Rules
    class SingleChannel < SingleRelation
      private

        def option_scope
          relation_class.visible
        end

        def relation_class
          Channel
        end
    end
  end
end