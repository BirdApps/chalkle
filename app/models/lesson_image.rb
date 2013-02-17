class LessonImage < ActiveRecord::Base
  attr_accessible :title, :pointsize, :lesson_id

  belongs_to :lesson, :inverse_of => :lesson_image

  #TODO validate title and pointsize format
  validates_presence_of :lesson
  validates_presence_of :title
  validates_presence_of :pointsize

  before_save :generate

  image_accessor :image

  private

  def generate
    self.image = File.new("#{Rails.root}/app/assets/images/lesson-bg.png")
    self.image.convert!(" \( -gravity center -font #{Rails.root}/app/assets/fonts/erasdust-webfont.ttf -background none -fill '#AAAAAA' -pointsize #{self.pointsize} label:'#{self.title}' +distort SRT '%[fx:w/2],%[fx:h/2] 1 354 215,225' \) -flatten")
  end

end
