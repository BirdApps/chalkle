class NoChalklersOnSixDegrees < ActiveRecord::Migration
  def up
    sixdegrees = Provider.find_by_url_name("sixdegrees")
    if sixdegrees
      sixdegrees.provider_teachers.update_all(chalkler_id: nil)
      updates = sixdegrees.provider_teachers.update_all(pseudo_chalkler_email: "asdasdasdasd@asdasdasd.com")
    end
    
    if updates
      puts "#{updates} teachers updated"
    else
      puts "no provider_teachers updated on sixdegrees"
    end

    if sixdegrees
      sixdegrees.provider_admins.update_all(chalkler_id: nil)
      updates = sixdegrees.provider_admins.update_all(pseudo_chalkler_email: "asdasdasdasd@asdasdasd.com")
    end
    
    if updates
      puts "#{updates} admins updated"
    else
      puts "no provider_admins updated on sixdegrees"
    end
  end

  def down
  end

end
