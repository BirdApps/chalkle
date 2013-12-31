class AddShortDescriptionToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :short_description, :string
  end
end
