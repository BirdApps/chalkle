class DropCostModels < ActiveRecord::Migration
  def up
    drop_table :cost_models
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
