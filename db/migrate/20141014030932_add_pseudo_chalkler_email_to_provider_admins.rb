class AddPseudoChalklerEmailToProviderAdmins < ActiveRecord::Migration
  def change
    add_column :provider_admins, :pseudo_chalkler_email, :string
  end
end
