class CreateProviderContacts < ActiveRecord::Migration
  def change
    create_table :provider_contacts do |t|
      t.integer :provider_id
      t.integer :chalkler_id
      t.string :to
      t.string :from
      t.string :subject
      t.string :message
      t.string :status
      t.timestamps
    end
  end
end
