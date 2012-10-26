require 'spec_helper'
require 'factory_girl'

describe Group do
  it "is invalid without a name" do
    FactoryGirl.build(:group, name: nil).should_not be_valid
  end

  it "is invalid without an API key" do
    FactoryGirl.build(:group, api_key: nil).should_not be_valid
  end
end
