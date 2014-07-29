require 'spec_helper_lite'
require 'finance/class_cost_calculators/percentage_commission'
require 'ostruct'
require 'finance/tax/null_tax'
require 'finance/tax/nz_gst'

module Finance
  module ClassCostCalculators
    describe PercentageCommission do
      ERROR_MARGIN = 0.000001

      let(:course) { OpenStruct.new(teacher_cost: 10.0, channel: nil) }
      let(:channel) { OpenStruct.new() }
      let(:subject_with_gst) { PercentageCommission.new(course, tax: Tax::NzGst.new, channel: channel) }
      subject { PercentageCommission.new(course, tax: Tax::NullTax.new, channel: channel) }

      describe "#channel_fee" do
        it "is zero if no teacher cost has been set" do
          course.teacher_cost = nil
          expect(subject.channel_fee).to eq 0
        end

        it "is zero if teacher percentage is zero" do
          channel.channel_rate_override = 0.5
          channel.teacher_percentage = 0.0
          expect(subject.channel_fee).to eq 0
        end

        it "returns the channel percentage of the estimated final cost" do
          course.teacher_cost = 10.0
          channel.channel_rate_override = 0.4
          channel.teacher_percentage = 0.5
          # estimated cost will be 20.0

          expect(subject.channel_fee).to be_within(ERROR_MARGIN).of(8.0) # 20.0 * 0.4
        end

        it "applies tax to channel fee" do
          course.teacher_cost = 10.0
          channel.channel_rate_override = 0.4
          channel.teacher_percentage = 0.5
          # estimated cost will be 20.0
          # pre-tax channel fee will be 8.0

          expect(subject_with_gst.channel_fee).to be_within(ERROR_MARGIN).of(9.2) # 8.0 * 1.15
        end
      end

      describe "#chalkle_fee" do
        it "is zero if no teacher cost has been set" do
          course.teacher_cost = nil
          expect(subject.chalkle_fee).to eq 0
        end

        it "is zero if teacher percentage is zero" do
          channel.channel_rate_override = 0.5
          channel.teacher_percentage = 0.0
          expect(subject.chalkle_fee).to eq 0
        end

        it "returns the chalkle percentage of the estimated final cost if no rounding is needed" do
          course.teacher_cost = 10.0
          channel.channel_rate_override = 0.4
          channel.teacher_percentage = 0.5
          # estimated cost will be 20.0

          expect(subject.chalkle_fee).to be_within(ERROR_MARGIN).of(2.0) # 20.0 * 0.1
        end

        it "rounds values up to the nearest dollar and includes the rounding amount in the chalkle fee" do
          course.teacher_cost = 9.8
          channel.channel_rate_override = 0.4
          channel.teacher_percentage = 0.5
          # estimated cost will be 19.6
          # rounding will be 0.4

          expect(subject.chalkle_fee).to be_within(ERROR_MARGIN).of(2.36) # (19.6 * 0.1) + 0.4
        end

        it "adds tax to the result" do
          course.teacher_cost = 10.0
          channel.channel_rate_override = 0.4
          channel.teacher_percentage = 0.5
          # estimated cost will be 20.0

          expect(subject_with_gst.total_cost).to be_within(ERROR_MARGIN).of(22.0)
          expect(subject_with_gst.chalkle_fee).to be_within(ERROR_MARGIN).of(2.8) # 20.0 * 0.1
        end
      end

      describe "#total_cost" do
        it "includes channel fee" do
          course.teacher_cost = 10.0
          channel.channel_rate_override = 0.5
          channel.teacher_percentage = 0.5

          expect(subject.total_cost).to be_within(ERROR_MARGIN).of(20.0)
        end

        it "includes chalkle fee" do
          course.teacher_cost = 10.0
          channel.channel_rate_override = 0.0
          channel.teacher_percentage = 0.5

          expect(subject.total_cost).to be_within(ERROR_MARGIN).of(20.0)
        end

        it "includes chalkle and channel fee" do
          course.teacher_cost = 10.0
          channel.channel_rate_override = 0.3
          channel.teacher_percentage = 0.5

          expect(subject.total_cost).to be_within(ERROR_MARGIN).of(20.0)
        end

        it "includes rounding" do
          course.teacher_cost = 10.0
          channel.channel_rate_override = 0.2
          channel.teacher_percentage = 0.6

          expect(subject.total_cost).to be_within(ERROR_MARGIN).of(17.0)
        end

        it "includes material cost" do
          course.teacher_cost = 7.0
          course.material_cost = 3.0
          channel.channel_rate_override = 0.2
          channel.teacher_percentage = 0.6

          expect(subject.total_cost).to be_within(ERROR_MARGIN).of(17.0)
        end
      end
    end
  end
end