class DropChalklerEmailStreams < ActiveRecord::Migration
  def up
    remove_column :chalklers, :email_streams
  end

  def down
    add_column :chalklers, :email_streams, :text
  end
end
