require 'spec_helper'

describe City do
  describe "creation" do
    specify { expect(FactoryGirl.build(:city)).to be_valid }
    it { should validate_presence_of(:name) }
  end
end
