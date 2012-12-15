require 'spec_helper'

describe Payment do
  it { should validate_uniqueness_of(:xero_id) }

  describe ".show_visible_only" do
    context "show visible only should include visible payment" do
      let(:payment) { FactoryGirl.create(:payment, visible: true) }
      it { Payment.show_visible_only.should include(payment) }
   	end

   	context "show visible only should not include invisible payment" do
      let(:payment) { FactoryGirl.create(:payment, visible: false) }
      it { Payment.show_visible_only.should_not include(payment) }
   	end

  describe ".show_invisible_only" do
    context "show invisible only should include invisible payment" do
      let(:payment) { FactoryGirl.create(:payment, visible: false) }
      it { Payment.show_invisible_only.should include(payment) }
   	end

   	context "show invisible only should not include visible payment" do
      let(:payment) { FactoryGirl.create(:payment, visible: true) }
      it { Payment.show_invisible_only.should_not include(payment) }
   	end

  end

end
