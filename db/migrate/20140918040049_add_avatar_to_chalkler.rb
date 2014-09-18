class AddAvatarToChalkler < ActiveRecord::Migration
  def change
    add_column :chalklers, :avatar, :string
  end
end
