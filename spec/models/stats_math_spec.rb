require 'spec_helper'

describe "Stats_math" do
  let(:stats_math) { StatsMath.new([1,2,3,4,5]) }

  describe "calculations" do
  	it "calculates average of array" do
  	  stats_math.average("to_d").should == 3.to_d
  	end

  end

end
