require 'spec_helper_lite'
require 'week'

describe Month do
  describe "#to_weeks" do
    it "builds a week for each day of the week" do
      jan = Month.new(2013,1)
      weeks = jan.to_weeks
      weeks.to_a.length.should == 5
      weeks.first.first_day.should == Date.new(2012,12,31)
      weeks.first.last_day.should == Date.new(2013,1,6)
    end
  end
end

describe Week do
  let(:monday)   { Date.new(2013,1,7) }
  let(:friday)   { Date.new(2013,1,11) }
  let(:saturday) { Date.new(2013,1,12) }
  let(:sunday)   { Date.new(2013,1,13) }

  let(:week1)    { Week.containing(monday - 1) }
  let(:week2)    { Week.containing(monday) }

  describe ".containing" do
    it "builds a week starting with that date if date is a monday" do
      week = Week.containing(monday)
      week.first_day.should == monday
      week.last_day.should == sunday
    end

    it "build a week starting containing date it doesn't start with" do
      week = Week.containing(friday)
      week.first_day.should == monday
      week.last_day.should == sunday
    end
  end

  describe ".on_weekend?" do
    it "returns true if day is saturday or sunday" do
      Week.on_weekend?(monday).should   be_false
      Week.on_weekend?(friday).should   be_false
      Week.on_weekend?(saturday).should be_true
      Week.on_weekend?(sunday).should   be_true
    end
  end

  describe "using in range" do
    it "can have a range with just one week" do
      range = week1..week1
      range.to_a.should == [week1]
    end
  end

  describe "addition" do
    it "returns same week if adding zero" do
      (Week.current + 0).should == Week.current
    end

    it "returns next week if adding 1" do
      (Week.current + 1).should == Week.current.next
    end

    it "can return a week a long way in the future" do
      expected = Week.current
      10.times { expected = expected.next }
      (Week.current + 10).should == expected
    end
  end
end
