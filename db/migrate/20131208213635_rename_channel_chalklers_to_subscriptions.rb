class RenameChannelChalklersToSubscriptions < ActiveRecord::Migration
  def change
    rename_table :channel_chalklers, :subscriptions
  end
end
