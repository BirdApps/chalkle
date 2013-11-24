class AddChannelDescriptionAndUrl < ActiveRecord::Migration
  def change
    add_column :channels, :description, :text
    add_column :channels, :website_url, :string
  end
end
