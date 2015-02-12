class AddEmailProvidersToChalklers < ActiveRecord::Migration
  def up
  	add_column :chalklers, :email_providers, :text
  end

  def down
  	remove_column :chalklers, :email_providers
  end
end
