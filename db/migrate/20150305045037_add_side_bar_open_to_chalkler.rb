class AddSideBarOpenToChalkler < ActiveRecord::Migration
  def change
    add_column :chalklers, :sidebar_open, :boolean, default: true, null: false
  end
end
