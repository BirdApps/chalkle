class AddInvitableToChalkler < ActiveRecord::Migration
  def change

    add_column :chalklers, :invitation_token, :string
    add_column :chalklers, :invitation_created_at, :datetime
    add_column :chalklers, :invitation_sent_at, :datetime
    add_column :chalklers, :invitation_accepted_at, :datetime
    add_column :chalklers, :invitation_limit, :integer
    add_column :chalklers, :invited_by_id, :integer
    add_column :chalklers, :invited_by_type, :string

    add_index :chalklers, :invitation_token, :unique => true

    change_column :chalklers, :encrypted_password, :string, :null => true

  end
end
