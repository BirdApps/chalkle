class AddCostModelIdToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :cost_model_id, :integer
    add_foreign_key :providers, :cost_models
  end
end
