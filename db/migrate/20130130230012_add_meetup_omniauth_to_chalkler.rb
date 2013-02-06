class AddMeetupOmniauthToChalkler < ActiveRecord::Migration
  def change
    add_column :chalklers, :provider, :string
    add_column :chalklers, :uid, :string
  end
end
