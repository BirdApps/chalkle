require 'spec_helper'

describe Venue do
  describe "creation" do
    specify { expect(FactoryGirl.build(:venue)).to be_valid }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:address_1) }
    it { should validate_presence_of(:city_id) }
  end
end
