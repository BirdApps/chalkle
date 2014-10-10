class AddBalanceToTeachers < ActiveRecord::Migration
  def change
    add_column :channel_teachers, :balance, :decimal
  end
end
