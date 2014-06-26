class RemoveWellingtonChalklersFromWellingtonRegion < ActiveRecord::Migration
  def up
    wellington_region_id = Region.where(name: 'Wellington').map(&:id).first
    wellington_channel_chalklers = Chalkler.all.select do |c| 
      c.channels.include? Channel.where(name: "Wellington").first.id 
    end

    transaction do 
      wellington_channel_chalklers.each do |c| 
        c.email_region_ids + wellington_region_id 
        c.channels.delete Channel.where(name: "Wellington").first
        if c.save
          puts "#{c.name} removed from wellington channel"
        else
          puts "#{c.name} removed from wellington channel FAILED"
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
