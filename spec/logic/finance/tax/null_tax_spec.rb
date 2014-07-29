require 'spec_helper_lite'
require 'finance/tax/null_tax'

module Finance::Tax
  describe NullTax do
    describe "#apply_to" do
      it "returns the value unchanged" do
        expect(subject.apply_to('foobar')).to eq 'foobar'
      end
    end
  end
end