require 'spec_helper_lite'
require 'finance/class_cost_calculators/flat_rate_markup'
require 'ostruct'
require 'finance/tax/null_tax'
require 'finance/tax/nz_gst'
require 'finance/markup/null_markup'
require 'finance/markup/credit_card_processing_fee'

module Finance
  module ClassCostCalculators
    describe FlatRateMarkup do
      ERROR_MARGIN = 0.000001

      let(:lesson) { OpenStruct.new(teacher_cost: 10.0, channel: nil) }
      let(:rates)  { {channel_fee: 2.0, chalkle_fee: 3.0} }
      subject { FlatRateMarkup.new(lesson, tax: Tax::NullTax.new, total_markup: Markup::NullMarkup.new, rates: rates) }
      let(:subject_with_tax) { FlatRateMarkup.new(lesson, tax: Tax::NzGst.new, total_markup: Markup::NullMarkup.new, rates: rates) }
      let(:subject_with_markup) { FlatRateMarkup.new(lesson, tax: Tax::NullTax.new, total_markup: Markup::CreditCardProcessingFee.new(0.5), rates: rates) }

      describe "#channel_fee" do
        it "should be equal to supplied constant" do
          subject.channel_fee.should == 2.0
        end

        it "has no tax on channel fee" do
          subject_with_tax.channel_fee.should == 2.0
        end
      end

      describe "#chalkle_fee" do
        it "should be equal to supplied constant" do
          subject.chalkle_fee.should == 3.0
        end

        it "has adds tax on top of the constant" do
          subject_with_tax.chalkle_fee.should be_within(ERROR_MARGIN).of(3.45)
        end
      end

      describe "#rounding" do
        it "should round the total to the next dollar" do
          subject_with_tax.rounding.should be_within(ERROR_MARGIN).of(0.55)
        end

        it "should calculate rounding after markup" do
          subject_with_markup.rounding.should be_within(ERROR_MARGIN).of(0.5) # 15 * 1.5 = 22.5, rounded up to 23
        end
      end

      describe "#total_cost" do
        it "should add the channel and chalkle fee onto the teacher cost" do
          subject.total_cost.should be_within(ERROR_MARGIN).of(15.00)
        end

        it "should include material cost" do
          lesson.material_cost = 5.0
          subject.total_cost.should be_within(ERROR_MARGIN).of(20.00)
        end

        it "is affected by overall markup" do
          subject_with_markup.total_cost.should be_within(ERROR_MARGIN).of(23) # 15 * 1.5 = 22.5, rounded up to 23
        end
      end
    end
  end
end