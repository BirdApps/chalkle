class AddHeroToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :hero, :string
  end
end
