class AddEmailCategoriesToChalklers < ActiveRecord::Migration
  def change
    add_column :chalklers, :email_categories, :text
  end
end
