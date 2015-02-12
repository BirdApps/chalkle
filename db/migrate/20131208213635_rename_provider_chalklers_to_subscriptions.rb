class RenameProviderChalklersToSubscriptions < ActiveRecord::Migration
  def change
    rename_table :provider_chalklers, :subscriptions
  end
end
