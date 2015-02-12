class AddProviderAdminIdToProviderAdmin < ActiveRecord::Migration
  def change
    add_column :provider_admins, :id, :primary_key
  end
end
