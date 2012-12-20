require 'spec_helper'

describe Payment do
  it { should validate_uniqueness_of(:xero_id) }

  let(:payment) { FactoryGirl.create(:payment) }

  describe ".visible" do
    it {Payment.visible.should include(payment)}

   	it "should not include hidden payment" do
      payment.visible = false
      payment.save
      Payment.visible.should_not include(payment)
   	end
  end

  describe ".hidden" do
    it "should include hidden payment" do
      payment.visible = false
      payment.save
      Payment.hidden.should include(payment)
   	end

   	it {Payment.hidden.should_not include(payment)}
  end

end
