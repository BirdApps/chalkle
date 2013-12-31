class AddCostCalculatorToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :cost_calculator, :string
  end
end
