require 'spec_helper'

describe LessonImage do
  it { should belong_to :lesson }

  describe 'creation' do
    it "has a valid factory" do
      FactoryGirl.build(:lesson_image)
    end

    it { should validate_presence_of :title }
    it { should validate_presence_of :pointsize }
    it { should validate_presence_of :lesson }
  end
end
