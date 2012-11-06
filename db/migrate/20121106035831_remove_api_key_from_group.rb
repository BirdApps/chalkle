class RemoveApiKeyFromGroup < ActiveRecord::Migration
  def up
    remove_column :groups, :api_key
  end

  def down
    add_column :groups, :api_key, :string
  end
end
