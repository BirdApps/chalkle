class AddMeetupUrlToProviders < ActiveRecord::Migration
  def up
    add_column :providers, :meetup_url, :string
    execute "UPDATE providers SET meetup_url = 'http://www.meetup.com/sixdegrees/' WHERE name = 'Wellington'"
  end

  def down
    remove_column :providers, :meetup_url
  end
end
