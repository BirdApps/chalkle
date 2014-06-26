class RemoveWellingtonChalklersFromWellingtonRegion < ActiveRecord::Migration
  def up
    wellington_region_id = Region.where(name: 'Wellington').map(&:id).first
    wellington_channel = Channel.where(name: "Wellington").first

    wellington_channel_chalklers = Chalkler.all.select do |c| 
      c.channels.include? wellington_channel
    end

    transaction do 
      wellington_channel_chalklers.each do |c| 
        if c.email_region_ids 
          c.email_region_ids << wellington_region_id 
        else
          c.email_region_ids = [wellington_region_id]
        end

        c.channels.delete wellington_channel
      end
    end
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
