class AddAvatarToProviderTeacher < ActiveRecord::Migration
  def change
    add_column :provider_teachers, :avatar, :string
  end
end
