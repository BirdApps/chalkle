class MarkPreV2ReleaseOutgoingsInvalid < ActiveRecord::Migration
   def up
    #all these outgoing payments were calculated before v2 release therefore not valid
    OutgoingPayment.valid.each do |o| 
      if o.last_booking.created_at < DateTime.new(2014,10,12)
        o.update_attribute("status", "not_valid") 
        o.update_attribute("reference", "Pre v2 release") 
      end
    end  
  end

  def down
  end
end
