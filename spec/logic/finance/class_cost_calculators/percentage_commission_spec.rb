require 'spec_helper_lite'
require 'finance/class_cost_calculators/percentage_commission'
require 'ostruct'
require 'finance/tax/null_tax'
require 'finance/tax/nz_gst'

module Finance
  module ClassCostCalculators
    describe PercentageCommission do
      ERROR_MARGIN = 0.000001

      let(:lesson) { OpenStruct.new(teacher_cost: 10.0) }
      let(:subject_with_gst) { PercentageCommission.new(lesson, Tax::NzGst.new) }
      subject { PercentageCommission.new(lesson, Tax::NullTax.new) }

      describe "#channel_fee" do
        it "is zero if no teacher cost has been set" do
          lesson.teacher_cost = nil
          subject.channel_fee.should == 0
        end

        it "is zero if teacher percentage is zero" do
          lesson.channel_percentage = 0.5
          lesson.chalkle_percentage = 0.5
          subject.channel_fee.should == 0
        end

        it "returns the channel percentage of the estimated final cost" do
          lesson.teacher_cost = 10.0
          lesson.channel_percentage = 0.4
          lesson.chalkle_percentage = 0.1
          # teacher percentage will be 0.5
          # estimated cost will be 20.0

          subject.channel_fee.should be_within(ERROR_MARGIN).of(8.0) # 20.0 * 0.4
        end

        it "applies tax to channel fee" do
          lesson.teacher_cost = 10.0
          lesson.channel_percentage = 0.4
          lesson.chalkle_percentage = 0.1

          subject_with_gst.channel_fee.should be_within(ERROR_MARGIN).of(9.2)
        end
      end

      describe "#chalkle_fee" do
        it "is zero if no teacher cost has been set" do
          lesson.teacher_cost = nil
          subject.chalkle_fee.should == 0
        end

        it "is zero if teacher percentage is zero" do
          lesson.channel_percentage = 0.5
          lesson.chalkle_percentage = 0.5
          subject.chalkle_fee.should == 0
        end

        it "returns the chalkle percentage of the estimated final cost if no rounding is needed" do
          lesson.teacher_cost = 10.0
          lesson.channel_percentage = 0.4
          lesson.chalkle_percentage = 0.1
          # teacher percentage will be 0.5
          # estimated cost will be 20.0

          subject.chalkle_fee.should be_within(ERROR_MARGIN).of(2.0) # 20.0 * 0.1
        end

        it "rounds values up to the nearest dollar and includes the rounding amount in the chalkle fee" do
          lesson.teacher_cost = 9.8
          lesson.channel_percentage = 0.4
          lesson.chalkle_percentage = 0.1
          lesson.cost = 20.0
          # teacher percentage will be 0.5
          # estimated cost will be 19.6
          # rounding will be 0.4

          subject.chalkle_fee.should be_within(ERROR_MARGIN).of(2.36) # (19.6 * 0.1) + 0.4
        end

        it "adds tax to the result" do
          lesson.teacher_cost = 10.0
          lesson.channel_percentage = 0.4
          lesson.chalkle_percentage = 0.1
          # teacher percentage will be 0.5
          # estimated cost will be 20.0

          subject_with_gst.chalkle_fee.should be_within(ERROR_MARGIN).of(2.3) # 20.0 * 0.1
        end
      end
    end
  end
end