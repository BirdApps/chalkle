require 'spec_helper'

describe Payment do
  it { should validate_uniqueness_of(:xero_id) }
  it { should validate_numericality_of(:total) }
  it "should not allow a nil value for total" do
    FactoryGirl.build(:payment, total: nil).should_not be_valid
  end

  it "should have a valid factory" do
    FactoryGirl.build(:payment).should be_valid
  end

  describe ".unreconcile" do
    it "unreconciles a payment" do
      booking = FactoryGirl.create(:booking)
      payment = FactoryGirl.create(:payment, booking: booking, reconciled: true)
      payment.unreconcile
      payment.reload.reconciled?.should be_false
      payment.reload.booking.should be_nil
    end
  end


  describe "scopes" do
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

end
