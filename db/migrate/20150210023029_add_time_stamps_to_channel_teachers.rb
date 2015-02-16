class AddTimeStampsToChannelTeachers < ActiveRecord::Migration
  def up
    add_column :channel_teachers, :created_at, :datetime
    add_column :channel_teachers, :updated_at, :datetime
  end

  def down
  end
end
