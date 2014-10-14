class AddPseudoChalklerEmailToChannelAdmins < ActiveRecord::Migration
  def change
    add_column :channel_admins, :pseudo_chalkler_email, :string
  end
end
