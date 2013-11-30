class AddMeetupUrlToChannels < ActiveRecord::Migration
  def up
    add_column :channels, :meetup_url, :string
    execute "UPDATE channels SET meetup_url = 'http://www.meetup.com/sixdegrees/' WHERE name = 'Wellington'"
  end

  def down
    remove_column :channels, :meetup_url
  end
end
