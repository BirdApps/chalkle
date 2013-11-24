class AddLogoToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :logo, :string
  end
end
