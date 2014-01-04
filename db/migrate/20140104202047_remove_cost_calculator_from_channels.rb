class RemoveCostCalculatorFromChannels < ActiveRecord::Migration
  def up
    remove_column :channels, :cost_calculator
  end

  def down
    add_column :channels, :cost_calculator, :string
  end
end
