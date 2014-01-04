class CostModel < ActiveRecord::Base
  attr_accessible :calculator_class_name

  def self.default
    first
  end

  def cost_calculator(options = {})
    cost_calculator_class.new(nil, options)
  end

  private

    def cost_calculator_class
      "Finance::ClassCostCalculators::#{calculator_class_name.camelcase}".constantize
    end

end