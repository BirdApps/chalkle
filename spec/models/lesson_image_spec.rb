# encoding: UTF-8
require 'spec_helper'

describe LessonImage do
  it { should belong_to :lesson }

  describe 'creation' do
    it 'has a valid factory' do
      FactoryGirl.build(:lesson_image)
    end

    it { should validate_presence_of :title }
    it { should validate_presence_of :lesson }
  end

  describe 'image generation' do
    it 'sanitizes the filename' do
      LessonImage.sanitize_filename('  title"ä*@').should == 'title____.png'
    end

    it 'sanitizes the title' do
      LessonImage.sanitize_title('title"%').should == 'title\"\%'
    end
  end
end
