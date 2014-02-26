class AddChalklerEmailRegions < ActiveRecord::Migration
  def up
    add_column :chalklers, :email_region_ids, :text
  end

  def down
    remove_column :chalklers, :email_region_ids
  end
end
