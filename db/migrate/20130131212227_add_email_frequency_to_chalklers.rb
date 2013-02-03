class AddEmailFrequencyToChalklers < ActiveRecord::Migration
  def change
    add_column :chalklers, :email_frequency, :string
  end
end
