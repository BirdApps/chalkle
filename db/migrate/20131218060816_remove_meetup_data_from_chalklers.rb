class RemoveMeetupDataFromChalklers < ActiveRecord::Migration
  def up
    remove_column :chalklers, :meetup_data
  end

  def down
    add_column :chalklers, :meetup_data, :text
  end
end
