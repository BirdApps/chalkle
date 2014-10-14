class ChangeBioToStringOnChannelTeachers < ActiveRecord::Migration
  def up
    change_column :channel_teachers, :bio, :text
  end

  def down
    change_column :channel_teachers, :bio, :string
  end
end
