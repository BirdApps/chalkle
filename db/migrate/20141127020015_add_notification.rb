class AddNotification < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string      :type
      t.datetime    :viewed_at
      t.datetime    :actioned_at
      t.references  :target, polymorphic: true
      t.text        :href
      t.text        :message
      t.string      :image
      t.timestamps
    end
  end
end
