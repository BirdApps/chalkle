require 'spec_helper'

describe CourseSuggestion do
  it { should belong_to(:category)}
  it { should have_many(:providers).through(:provider_course_suggestions) }

  specify { expect(FactoryGirl.build(:course_suggestion)).to be_valid }

  describe "validation" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :description }
  end

end
