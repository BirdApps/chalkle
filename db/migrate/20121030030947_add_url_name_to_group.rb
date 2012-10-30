class AddUrlNameToGroup < ActiveRecord::Migration
  def self.up
    add_column :groups, :url_name, :string
  end

  def self.down
    remove_column :groups, :url_name
  end
end
