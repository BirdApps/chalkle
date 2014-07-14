require 'spec_helper'
require 'carrierwave/test/matchers'

describe CourseUploadImageUploader do
  include CarrierWave::Test::Matchers

  before do
    CourseUploadImageUploader.enable_processing = true
    @course = FactoryGirl.create(:course)
    @uploader = CourseUploadImageUploader.new(@course, :course_upload_image)
    @uploader.store!(File.open("#{Rails.root}/app/assets/images/course-bg.png"))
  end

  after do
    CourseUploadImageUploader.enable_processing = false
    @uploader.remove!
    FileUtils.remove_dir("#{Rails.root}/public/uploads/test", :force => true)
  end

  context 'saved image' do
    it "should save the image in the right location" do
      File.exist?("#{Rails.root}/public/uploads/test/course/course_upload_image/#{@course.id}/course-bg.png")
    end
  end

  context 'file extension' do
    it "should only accept image files" do
      @uploader.extension_white_list.should =~ %w(jpg jpeg gif png)
    end
  end

end
