class AddNotification < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string      :notification_type
      t.datetime    :viewed_at
      t.datetime    :actioned_at
      t.datetime    :valid_from
      t.datetime    :valid_till
      t.references  :target, polymorphic: true
      t.text        :href
      t.text        :message
      t.string      :image
      t.timestamps
    end
  end
end
