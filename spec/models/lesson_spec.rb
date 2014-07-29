require 'spec_helper'

describe Lesson do
  it { should belong_to(:course)}

  specify { expect(FactoryGirl.create(:lesson)).to be_valid }

  let(:lesson) { FactoryGirl.create(:lesson) }

  describe "duration" do
    it "should be a positive float" do
      lesson.duration = -1.5
      expect(lesson).not_to be_valid
      lesson.duration = 1.5
      expect(lesson).to be_valid
    end
  end

end
