class SetPublishedAt < ActiveRecord::Migration
  def up
    execute "UPDATE lessons SET published_at = updated_at WHERE published_at IS NULL AND status = 'Published'"
  end

  def down
  end
end
