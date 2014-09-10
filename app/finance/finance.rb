module Finance
  class ChannelPlanCalculator
    attr_accessor :channel_plan
    def initilize(channel_plan)
      @channel_plan = channel_plan
    end

    def apply_costs_to(course)
      
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