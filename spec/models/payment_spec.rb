require 'spec_helper'

describe Payment do
  it { should validate_uniqueness_of(:xero_id) }

  describe ".visible" do
    it "should include visible payment" do
      payment = FactoryGirl.create(:payment, visible: true) 
      Payment.visible.should include(payment)
   	end

   	it "should not include hidden payment" do
      payment = FactoryGirl.create(:payment, visible: false) 
      Payment.visible.should_not include(payment) 
   	end
   end

  describe ".hidden" do
    it "should include hidden payment" do
      payment = FactoryGirl.create(:payment, visible: false) 
      Payment.hidden.should include(payment) 
   	end

   	it "should not include visible payment" do
      payment = FactoryGirl.create(:payment, visible: true) 
      Payment.hidden.should_not include(payment) 
   	end
  end

end
