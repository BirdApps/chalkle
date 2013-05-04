require 'spec_helper'

describe LessonSuggestion do
  it { should belong_to(:category)}
  it { should have_many(:channels).through(:channel_lesson_suggestions) }

  specify { FactoryGirl.build(:lesson_suggestion).should be_valid }

  describe "validation" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :description }
  end

end
