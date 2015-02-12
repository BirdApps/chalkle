class ChangeBioToStringOnProviderTeachers < ActiveRecord::Migration
  def up
    change_column :provider_teachers, :bio, :text
  end

  def down
    change_column :provider_teachers, :bio, :string
  end
end
