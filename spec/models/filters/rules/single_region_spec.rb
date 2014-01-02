require 'spec_helper'
require 'filters/rules/single_region'

module Filters::Rules
  describe SingleRegion do
    let(:region) { double(:region, id: 47) }
    let(:scope)  { double(:scope) }
    let(:rule)  { double(:rule) }

    describe "#apply_to" do
      it "applies the region to the scope" do
        subject.relation = region

        scope.should_receive(:only_with_region).with(region)
        subject.apply_to(scope)
      end
    end

    describe "#deserialise" do
      it "treats the value as a region id" do
        Region.should_receive(:find).with('23').and_return(region)
        subject.deserialize(double(:rule, value: '23'))
        subject.relation.should == region
      end
    end

    describe "#serialize" do
      it "stores the region id in the value" do
        rule.should_receive(:value=).with(47)
        subject.relation = region
        subject.serialize(rule)
      end
    end
  end
end