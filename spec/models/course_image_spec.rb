# encoding: UTF-8
require 'spec_helper'

describe CourseImage do
  it { should belong_to :course }

  describe 'creation' do
    it 'has a valid factory' do
      FactoryGirl.build(:course_image)
    end

    it { should validate_presence_of :title }
    it { should validate_presence_of :course }
  end

  describe 'image generation' do
    it 'sanitizes the filename' do
      expect(CourseImage.sanitize_filename('  title"ä*@')).to eq 'title____.png'
    end

    it 'sanitizes the title' do
      expect(CourseImage.sanitize_title('title"%')).to eq 'title\"\%'
    end
  end
end
