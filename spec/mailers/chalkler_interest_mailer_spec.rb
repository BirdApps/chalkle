require "spec_helper"

describe ChalklerInterestMailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  describe "Daily digest mail content" do
  	let(:lesson) { FactoryGirl.create(:lesson, cost: 10) }
    let(:chalkler) { FactoryGirl.create(:chalkler) }
    

  end
end
