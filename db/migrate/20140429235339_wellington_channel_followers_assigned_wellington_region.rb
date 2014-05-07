class WellingtonChannelFollowersAssignedWellingtonRegion < ActiveRecord::Migration
  def up
    if wellington_region_id = Region.find_by_name("Wellington").try(:id)
      wellington_chalklers = Channel.where(name: "Wellington").map(&:chalklers).flatten!
      transaction do 
        wellington_chalklers.each {|wc| 
          if wc.email_region_ids 
            wc.email_region_ids << wellington_region_id 
          else 
              wc.email_region_ids = [ wellington_region_id ]
          end
          if wc.save
            puts "Chalkler \"#{wc.name}\" added to wellington region" 
          end
        }
      end
    end
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
