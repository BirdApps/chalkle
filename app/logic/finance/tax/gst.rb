module Gst

  extend ActiveSupport::Concern

  included do 
    def self.gst_rate_for(tax_code)
      case tax_code
      when :nz
        0.15
      else
        0
      end
    end
  end

end
