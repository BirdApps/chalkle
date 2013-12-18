class RemoveUidAndProviderFromChalklers < ActiveRecord::Migration
  def up
    remove_column :chalklers, :uid
    remove_column :chalklers, :provider
  end

  def down
    add_column :chalklers, :uid, :string
    add_column :chalklers, :provider, :string
  end
end
