# encoding: utf-8
class CourseNoticeUploader < ChalkleBaseImageUploader
  process :resize_to_fit => [600, 600]
end
