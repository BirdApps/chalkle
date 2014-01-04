class CreateCostModels < ActiveRecord::Migration
  def change
    create_table :cost_models do |t|
      t.string :calculator_class_name, length: 50
    end
  end
end
