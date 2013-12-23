require 'spec_helper_lite'
require 'finance/class_cost_calculators/percentage_commission'

module Finance
  module ClassCostCalculators
    describe PercentageCommission do
      describe "#channel_fee" do
        it "is zero if no teacher cost has been set"
        it "is zero if teacher percentage is zero"
        #it "does complex stuff"
      end

      describe "#chalkle_fee" do
        it "is zero if no teacher cost has been set"
        it "is zero if teacher percentage is zero"
      end
    end
  end
end