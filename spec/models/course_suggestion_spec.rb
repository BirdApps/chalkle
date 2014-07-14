require 'spec_helper'

describe CourseSuggestion do
  it { should belong_to(:category)}
  it { should have_many(:channels).through(:channel_course_suggestions) }

  specify { FactoryGirl.build(:course_suggestion).should be_valid }

  describe "validation" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :description }
  end

end
