class AddAccountToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :account, :string, :default => nil
  end 
end
