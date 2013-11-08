class Category < ActiveRecord::Base
  attr_accessible :name, :colour_num, :parent_id, :parent, as: :default
  attr_accessible :name, :colour_num, :parent_id, :parent, as: :admin

  has_many :channel_categories
  has_many :channels, :through => :channel_categories
  has_many :lesson_categories
  has_many :lessons, :through => :lesson_categories
  belongs_to :parent, class_name: 'Category'
  has_many :children, class_name: 'Category', foreign_key: :parent_id

  scope :primary, where(primary: true)
  scope :alphabetical, order(:name)

  validates_presence_of :name

  #TODO: Move into a presenter class like Draper sometime
  #FIXME: Data should be enforced in some convention so lowercase conversion is not required here (probably all lowercase)
  def self.select_options(indent = '+-- ')
    results = []
    primary.alphabetical.all.each do |category|
      results << [category.name, category.id]
      category.children.each do |child|
        results << [indent + child.name, child.id]
      end
    end
    results
  end

  def best_colour_num
    colour_num || parent_best_colour_num
  end

  private

    def parent_best_colour_num
      parent.best_colour_num if parent
    end
end
