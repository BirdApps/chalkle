class AddChalklerToChannelAdmin < ActiveRecord::Migration
  def change
    add_column :channel_admins, :chalkler_id, :integer
    add_foreign_key :channel_admins, :chalklers
  end
end
