class AddEmailToProviders < ActiveRecord::Migration
  def up
  	add_column :providers, :email, :string, :default => nil
  end

  def down
  	remove_column :providers, :email
  end
end
