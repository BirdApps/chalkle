class RemoveMeetupIdFromChalklers < ActiveRecord::Migration
  def up
    remove_column :chalklers, :meetup_id
  end

  def down
    add_column :chalklers, :meetup_id, :integer
    execute "UPDATE chalklers SET meetup_id = uid"
  end
end
