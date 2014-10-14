class ChangeMessageStringToTextOnChannelContact < ActiveRecord::Migration
   def up
    change_column :channel_contacts, :message, :text
  end

  def down
    change_column :channel_contacts, :message, :string
  end
end
