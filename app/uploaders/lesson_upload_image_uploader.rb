# encoding: utf-8
require 'chalkle_base_image_uploader'

class LessonUploadImageUploader < ChalkleBaseImageUploader
  version :mini do
    process :resize_to_fill => [65, 65]
  end
  version :medium do
    process :resize_to_fill => [150, 150]
  end
  version :large do
    process :resize_to_fill => [200, 200]
  end
end
