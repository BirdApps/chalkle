class AddGstToChalkler < ActiveRecord::Migration
  def up
    add_column :chalklers, :gst, :string
  end

  def down
    remove_column :chalklers, :gst
  end
end
