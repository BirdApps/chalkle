require 'spec_helper_lite'
require 'date'
require 'daily_records_hash'

describe DailyRecordsHash do
  class Record
    attr_accessor :date
    def initialize(date)
      @date = date
    end
  end

  let(:day1) { Date.new(2013,1,1) }
  let(:day2) { Date.new(2013,1,2) }
  let(:day3) { Date.new(2013,1,3) }

  describe "constructing" do
    it "can be built with no records" do
      subject = DailyRecordsHash.new
      expect {|b| subject.each_day(&b) }.not_to yield_control
    end

    it "can be built with records" do
      record1 = Record.new(day1)
      record2 = Record.new(day2)
      subject = DailyRecordsHash.new([record1, record2])
      expect {|b| subject.each_day(&b)}.to yield_successive_args(
        [day1, [record1]],
        [day2, [record2]]
      )
    end
  end

  describe "adding records" do
    it "adds them to the records available" do
      record1 = Record.new(day1)
      record2 = Record.new(day1)
      subject = DailyRecordsHash.new([record1])
      subject.add_records [record2]
      expect {|b| subject.each_day(&b)}.to yield_successive_args(
         [day1, [record1, record2]]
       )
    end
  end

  describe "#empty?" do
    it "is true if no records have been added" do
      subject = DailyRecordsHash.new
      subject.should be_empty
    end

    it "is false if record has been added" do
      subject = DailyRecordsHash.new
      subject.add_records [Record.new(day1)]
      subject.should_not be_empty
    end
  end

  describe "indexing by day" do
    it "can be done with index operator" do
      record1 = Record.new(day1)
      subject = DailyRecordsHash.new [record1]
      subject[record1.date].should == [record1]
    end
  end
end