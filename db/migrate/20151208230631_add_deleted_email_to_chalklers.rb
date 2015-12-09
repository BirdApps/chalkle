class AddDeletedEmailToChalklers < ActiveRecord::Migration
  def change
    add_column :chalklers, :deleted_email, :string, null: true
  end
end
