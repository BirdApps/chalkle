require 'spec_helper'
require 'carrierwave/test/matchers'

describe LessonUploadImageUploader do
  include CarrierWave::Test::Matchers

  before do
    LessonUploadImageUploader.enable_processing = true
    @lesson = FactoryGirl.create(:lesson)
    @uploader = LessonUploadImageUploader.new(@lesson, :lesson_upload_image)
    @uploader.store!(File.open("#{Rails.root}/app/assets/images/lesson-bg.png"))
  end

  after do
    LessonUploadImageUploader.enable_processing = false
    @uploader.remove!
    FileUtils.remove_dir("#{Rails.root}/public/uploads/test", :force => true)
  end

  context 'saved image' do
    it "should save the image in the right location" do
      File.exist?("#{Rails.root}/public/uploads/test/lesson/lesson_upload_image/#{@lesson.id}/lesson-bg.png")
    end
  end

  context 'file extension' do
    it "should only accept image files" do
      @uploader.extension_white_list.should =~ %w(jpg jpeg gif png)
    end
  end

end
