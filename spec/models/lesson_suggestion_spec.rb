require 'spec_helper'

describe LessonSuggestion do
  it { should belong_to(:category)}
  it { should have_many(:channels).through(:channel_lesson_suggestions) }
  it { should validate_presence_of :name }
  it { should validate_presence_of :description }

  specify { FactoryGirl.create(:lesson_suggestion).should be_valid }
end
