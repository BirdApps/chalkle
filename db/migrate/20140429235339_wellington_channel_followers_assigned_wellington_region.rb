class WellingtonChannelFollowersAssignedWellingtonRegion < ActiveRecord::Migration
  def up
    wellington_region_id = Region.find_by_name("Wellington").id
    wellington_chalklers = Channel.where(name: "Wellington").map(&:chalklers).flatten!
    transaction do 
      wellington_chalklers.each {|wc| 
        wc.email_region_ids << wellington_region_id 
        if wc.save
          puts "Chalkler \"#{wc.name}\" added to wellington region" 
        end
      }
    end
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
