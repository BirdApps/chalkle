class AddFilterIdToRules < ActiveRecord::Migration
  def change
    add_column :filter_rules, :filter_id, :integer
    add_foreign_key :filter_rules, :filters
  end
end
