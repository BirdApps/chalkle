class AddProviderDataToIdentities < ActiveRecord::Migration
  def change
    add_column :omniauth_identities, :provider_data, :text
  end
end
