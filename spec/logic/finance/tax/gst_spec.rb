require 'spec_helper_lite'
require 'finance/tax/gst'

module Finance::Tax
  describe Gst do
    describe "#gst_rate_for" do
      it "returns the gst rate for a country code" do
        subject.gst_rate_for(:nz).should be_within(0.0000001).of(115.0)
      end
    end
  end
end