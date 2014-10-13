class ChangeMessageToTextOnChannelContacts < ActiveRecord::Migration
  def change
    change_column :channel_contacts, :message, :text 

  end
end
