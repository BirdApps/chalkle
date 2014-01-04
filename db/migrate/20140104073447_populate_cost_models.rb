class PopulateCostModels < ActiveRecord::Migration
  class CostModel < ActiveRecord::Base
    attr_accessible :calculator_class_name
  end

  def up
    CostModel.create(calculator_class_name: 'flat_rate_markup')
    CostModel.create(calculator_class_name: 'percentage_commission')
  end

  def down
    CostModel.delete_all
  end
end
