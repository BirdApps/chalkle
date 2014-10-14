class SetChalklersToVisible < ActiveRecord::Migration
  def up
    Chalkler.update_all "visible = TRUE"
  end

  def down
  end
end
