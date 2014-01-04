class AddCostModelIdToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :cost_model_id, :integer
    add_foreign_key :channels, :cost_models
  end
end
