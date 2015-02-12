class DropFiltersTable < ActiveRecord::Migration
  def up
    remove_column :providers, :cost_model_id
    drop_table :filter_rules
    drop_table :filters
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
