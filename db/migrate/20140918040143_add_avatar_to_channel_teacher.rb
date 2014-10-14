class AddAvatarToChannelTeacher < ActiveRecord::Migration
  def change
    add_column :channel_teachers, :avatar, :string
  end
end
