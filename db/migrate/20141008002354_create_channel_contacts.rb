class CreateChannelContacts < ActiveRecord::Migration
  def change
    create_table :channel_contacts do |t|
      t.integer :channel_id
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
