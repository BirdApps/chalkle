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
      CourseImage.sanitize_filename('  title"ä*@').should == 'title____.png'
    end

    it 'sanitizes the title' do
      CourseImage.sanitize_title('title"%').should == 'title\"\%'
    end
  end
end
