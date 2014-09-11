module Finance
  class ChannelPlanCalculator
    attr_accessor :channel_plan
    
    def initilize(channel_plan)
      @channel_plan = channel_plan
    end

    def apply_costs_to(course)
      if course.channel_id
        @channel = Channel.find(course.channel_id) 
      else
        @channel = Channel.new
      end

      @channel_fee = channel.fee

      if course.course?
        @chalkle_fee = @channel_plan.class_attendee_cost
      else
        @chalkle_fee = @channel_plan.course_attendee_cost
      end

      @cost = @chalkle_fee+@channel_fee

      @processing_fee = @cost * @channel_plan.processing_fee_percent

      @cost = @cost + @processing_fee
      #TODO: make an actual calculator that works
      {
        cost: @cost
        channel_fee: @channel_fee
        chalkle_fee: @chalkle_fee
        processing_fee: @processing_fee
        max_profit: 2
        min_profit: 2
      }
    end
  end

  def self.sales_tax_for(country_code)
    case country_code
      when :nz
        0.15
      else
        0
      end
  end
end