class AddTaxAndAccountToChannelTeacher < ActiveRecord::Migration
  def change
    add_column :channel_teachers, :tax_number, :string
    add_column :channel_teachers, :account, :string
  end
end
