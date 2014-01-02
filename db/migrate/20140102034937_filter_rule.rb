class FilterRule < ActiveRecord::Migration
  def up
    create_table :filter_rules do |t|
      t.string :strategy_name
      t.string :value
    end
  end

  def down
    drop_table :filter_rules
  end
end
