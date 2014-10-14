class AddChannelAdminIdToChannelAdmin < ActiveRecord::Migration
  def change
    add_column :channel_admins, :id, :primary_key
  end
end
