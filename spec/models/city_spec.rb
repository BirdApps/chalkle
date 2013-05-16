require 'spec_helper'

describe City do
  describe "creation" do
    specify { FactoryGirl.build(:city).should be_valid }
    it { should validate_presence_of(:name) }
  end
end
