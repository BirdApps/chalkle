class AddSuperToAdminUser < ActiveRecord::Migration
  def self.up
    add_column :admin_users, :super, :boolean, :default => false
  end

  def self.down
    remove_column :admin_users, :super
  end
end
