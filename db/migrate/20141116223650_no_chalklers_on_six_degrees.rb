class NoChalklersOnSixDegrees < ActiveRecord::Migration
  def up
    sixdegrees = Channel.find_by_url_name("sixdegrees")
    if sixdegrees
      sixdegrees.channel_teachers.update_all(chalkler_id: nil)
      updates = sixdegrees.channel_teachers.update_all(pseudo_chalkler_email: "asdasdasdasd@asdasdasd.com")
    end
    
    if updates
      puts "#{updates} teachers updated"
    else
      puts "no channel_teachers updated on sixdegrees"
    end

    if sixdegrees
      sixdegrees.channel_admins.update_all(chalkler_id: nil)
      updates = sixdegrees.channel_admins.update_all(pseudo_chalkler_email: "asdasdasdasd@asdasdasd.com")
    end
    
    if updates
      puts "#{updates} admins updated"
    else
      puts "no channel_admins updated on sixdegrees"
    end
  end

  def down
  end

end
