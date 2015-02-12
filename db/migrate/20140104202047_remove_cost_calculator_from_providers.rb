class RemoveCostCalculatorFromProviders < ActiveRecord::Migration
  def up
    remove_column :providers, :cost_calculator
  end

  def down
    add_column :providers, :cost_calculator, :string
  end
end
