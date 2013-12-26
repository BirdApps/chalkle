require 'spec_helper_lite'
require 'finance/tax/null_tax'

module Finance::Tax
  describe NullTax do
    describe "#apply_to" do
      it "returns the value unchanged" do
        subject.apply_to('foobar').should == 'foobar'
      end
    end
  end
end