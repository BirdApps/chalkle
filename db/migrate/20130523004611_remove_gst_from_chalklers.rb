class RemoveGstFromChalklers < ActiveRecord::Migration
  def change
    remove_column :chalklers, :gst
  end
end
