class AddAverageHeroColorToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :average_hero_color, :string
  end
end
