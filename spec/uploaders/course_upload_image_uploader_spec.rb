require 'spec_helper'
require 'carrierwave/test/matchers'

describe CourseUploadImageUploader do
  include CarrierWave::Test::Matchers

  let(:course){ FactoryGirl.create(:course) }
  let(:uploader){ CourseUploadImageUploader.new(course, :course_upload_image) }

  before(:each) do
    uploader.enable_processing = true
    uploader.store!(File.open("#{Rails.root}/app/assets/images/course-bg.png"))
  end

  after do
    uploader.enable_processing = false
    uploader.remove!
    FileUtils.remove_dir("#{Rails.root}/public/uploads/test", :force => true)
  end

  context 'saved image' do
    it "should save the image in the right location" do
      File.exist?("#{Rails.root}/public/uploads/test/course/course_upload_image/#{course.id}/course-bg.png")
    end
  end

  context 'file extension' do
    it "should only accept image files" do
      uploader.extension_white_list.should =~ %w(jpg jpeg gif png)
    end
  end

end
