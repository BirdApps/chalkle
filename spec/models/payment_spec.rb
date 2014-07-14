require 'spec_helper'

describe Payment do
  it { should validate_uniqueness_of(:xero_id) }
  it { should validate_numericality_of(:total) }
  it "should not allow a nil value for total" do
    expect(FactoryGirl.build(:payment, total: nil)).not_to be_valid
  end

  it "should have a valid factory" do
    expect(FactoryGirl.build(:payment)).to be_valid
  end

  describe "scopes" do
    let(:payment) { FactoryGirl.create(:payment) }

    describe ".visible" do
      it { expect(Payment.visible).to include(payment) }

      it "should not include hidden payment" do
        payment.visible = false
        payment.save
        expect(Payment.visible).not_to include(payment)
      end
    end

    describe ".hidden" do
      it "should include hidden payment" do
        payment.visible = false
        payment.save
        expect(Payment.hidden).to include(payment)
      end

      it { expect(Payment.hidden).not_to include(payment) }
    end
  end

end
