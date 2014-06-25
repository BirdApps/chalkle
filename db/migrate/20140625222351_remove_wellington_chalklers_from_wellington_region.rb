class RemoveWellingtonChalklersFromWellingtonRegion < ActiveRecord::Migration
  def up
    wellington_region_id = Region.where(name: 'Wellington').map(&:id).first
    wellington_chalklers = Chalkler.all.select {|c| c.email_region_ids.include? wellington_region_id }

    transaction do 
      wellington_chalklers.each do |c| 
        c.email_region_ids.delete(wellington_region_id)
        if c.save
          puts "#{c.name} removed from wellington region"
        else
          puts "#{c.name} removed from wellington region FAILED"
          puts c.errors
          raise ActiveRecord::Rollback
        end
      end
    end
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
