require 'spec_helper'

describe "Stats_math" do
  let(:stats_math) { Stats_math.new([1,2,3,4,5]) }

  describe "calculations" do
  	it "calculates average of array" do
  	  stats_math.average().should == 3
  	end

    it "calucates percentage changes" do
      stats_math.percent_change[0].should == -50
    end

  end

end
