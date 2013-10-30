class Category < ActiveRecord::Base
  attr_accessible :name, :colour_num, :parent_id, :parent, as: :default
  attr_accessible :name, :colour_num, :parent_id, :parent, as: :admin

  has_many :channel_categories
  has_many :channels, :through => :channel_categories
  has_many :lesson_categories
  has_many :lessons, :through => :lesson_categories
  belongs_to :parent, class_name: 'Category'

  validates_presence_of :name

  #TODO: Move into a presenter class like Draper sometime
  #FIXME: Data should be inforced in some convention so lowercase conversion is not required here (probably all lowercase)
  def self.select_options
    all(order: "name").map { |c| [c.name, c.id] }
  end

  def best_colour_num
    colour_num || parent_best_colour_num
  end

  private

    def parent_best_colour_num
      parent.best_colour_num if parent
    end
end
