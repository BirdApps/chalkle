class CreateInteraction < ActiveRecord::Migration
  def change
    create_table :interactions do |t|
      t.string :action
      t.string :controller
      t.string :flag
      t.string :request_ip
      t.references :actor, polymorphic: true
      t.references :target, polymorphic: true
      t.timestamps
    end
  end
end
