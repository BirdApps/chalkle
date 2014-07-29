require 'spec_helper_lite'
require 'week'

describe Month do
  describe "#to_weeks" do
    it "builds a week for each day of the week" do
      jan = Month.new(2013,1)
      weeks = jan.to_weeks
      weeks.to_a.length.should eq 5
      weeks.first.first_day.should eq Date.new(2012,12,31)
      weeks.first.last_day.should eq Date.new(2013,1,6)
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
      expect(week.first_day).to eq monday
      expect(week.last_day).to eq sunday
    end

    it "build a week starting containing date it doesn't start with" do
      week = Week.containing(friday)
      expect(week.first_day).to eq monday
      expect(week.last_day).to eq sunday
    end
  end

  describe ".on_weekend?" do
    it "returns true if day is saturday or sunday" do
      expect(Week.on_weekend?(monday)).to   eq false
      expect(Week.on_weekend?(friday)).to   eq false
      expect(Week.on_weekend?(saturday)).to eq true
      expect(Week.on_weekend?(sunday)).to   eq true
    end
  end

  describe "using in range" do
    it "can have a range with just one week" do
      range = week1..week1
      expect(range.to_a).to eq [week1]
    end
  end

  describe "addition" do
    it "returns same week if adding zero" do
      expect((Week.current + 0)).to eq Week.current
    end

    it "returns next week if adding 1" do
      expect((Week.current + 1)).to eq Week.current.next
    end

    it "can return a week a long way in the future" do
      expected = Week.current
      10.times { expected = expected.next }
      expect(Week.current + 10).to eq expected
    end
  end
end
