class RemoveWellingtonChalklersFromWellingtonRegion < ActiveRecord::Migration
  def up
    wellington_region_id = Region.where(name: 'Wellington').map(&:id).first
    wellington_provider = Provider.where(name: "Wellington").first

    wellington_provider_chalklers = Chalkler.all.select do |c| 
      c.providers.include? wellington_provider
    end

    transaction do 
      wellington_provider_chalklers.each do |c| 
        if c.email_region_ids 
          c.email_region_ids << wellington_region_id 
        else
          c.email_region_ids = [wellington_region_id]
        end

        c.providers.delete wellington_provider
      end
    end
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
