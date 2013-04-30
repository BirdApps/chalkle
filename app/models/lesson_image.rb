class LessonImage < ActiveRecord::Base
  attr_accessible :title, :lesson_id, :as => :admin

  belongs_to :lesson, :inverse_of => :lesson_image

  validates_presence_of :lesson
  validates_presence_of :title

  before_save :generate

  image_accessor :image

  def self.sanitize_filename(filename)
    filename = filename.strip
    filename = filename.gsub(/^.*(\\|\/)/, '')
    filename = filename.gsub(/[^0-9A-Za-z.\-]/, '_')
    "#{filename}.png"
  end

  def self.sanitize_title(title)
    title = title.gsub(/"/, '\\\\"')
    title.gsub(/%/, '\\%')
  end

  private

  def generate
    self.image = File.new("#{Rails.root}/app/assets/images/lesson-bg.png")
    title = LessonImage.sanitize_title(self.title)
    self.image.convert!(" \( -gravity center -font #{Rails.root}/app/assets/fonts/mrchalk.ttf -background none -fill '#AAAAAA' -size 400x350 label:\"#{title}\" +distort SRT '%[fx:w/2],%[fx:h/2] 1 354 215,225' \) -flatten")
    self.image.name = LessonImage.sanitize_filename(self.title)
  end

end
