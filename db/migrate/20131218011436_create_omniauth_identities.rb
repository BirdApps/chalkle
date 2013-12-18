class CreateOmniauthIdentities < ActiveRecord::Migration
  def change
    create_table "omniauth_identities", :force => true do |t|
      t.integer  "user_id"
      t.string   "email"
      t.string   "provider"
      t.string   "uid"
      t.string   "name"
    end

    add_index "omniauth_identities", ["email"]
    add_index "omniauth_identities", ["provider", "uid"]
    add_index "omniauth_identities", ["user_id"]
  end
end
