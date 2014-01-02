module Filters
  class Rule < ActiveRecord::Base
    self.table_name = 'filter_rules'

    belongs_to :filter, class_name: 'Filters::Filter'

    validates_presence_of :strategy_name

    delegate :apply_to, to: :strategy

    def strategy
      "Filters::Rules::#{strategy_name}".constantize.new(self)
    end
  end
end