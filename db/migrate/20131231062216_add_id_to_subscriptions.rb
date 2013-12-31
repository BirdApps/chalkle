class AddIdToSubscriptions < ActiveRecord::Migration
  def up
  	add_column :subscriptions, :id, :primary_key
  end

  def down
  	remove_column :subscriptions, :id
  end
end
