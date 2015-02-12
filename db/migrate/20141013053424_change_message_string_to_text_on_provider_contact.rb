class ChangeMessageStringToTextOnProviderContact < ActiveRecord::Migration
   def up
    change_column :provider_contacts, :message, :text
  end

  def down
    change_column :provider_contacts, :message, :string
  end
end
