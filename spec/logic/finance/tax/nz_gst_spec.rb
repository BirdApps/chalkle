require 'spec_helper_lite'
require 'finance/tax/nz_gst'

module Finance::Tax
  describe NzGst do
    describe "#apply_to" do
      it "adds 15% to number" do
        subject.apply_to(100.0).should be_within(0.0000001).of(115.0)
      end
    end
  end
end