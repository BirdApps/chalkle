class AddCostCalculatorToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :cost_calculator, :string
  end
end
