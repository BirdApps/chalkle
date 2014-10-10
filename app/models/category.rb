class Category < ActiveRecord::Base
  attr_accessible :name, :colour_num, :parent_id, :parent, as: :default
  attr_accessible :name, :colour_num, :parent_id, :parent, :primary, as: :admin

  has_many :channel_categories
  has_many :channels, :through => :channel_categories
  has_many :courses
  belongs_to :parent, class_name: 'Category'
  has_many :children, class_name: 'Category', foreign_key: :parent_id

  scope :primary, where(primary: true)
  scope :alphabetical, order(:name)

  validates_presence_of :name
  validates_uniqueness_of :name

  def hero
    nil
  end

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

  def self.ordered
    results = []
      primary.alphabetical.all.each do |category|
        results << category
        category.children.each do |child|
          results << child
        end
      end
    results
  end

  def self.ordered_with_classes
    ordered & with_displayable_classes_in_future
  end

  def self.with_displayable_classes_in_future
    categories = []
    Category.all.each do |category|
      categories << category if category.courses.in_future.displayable.count > 0
    end
    categories
  end

  def best_colour_num
    colour_num || parent_best_colour_num
  end

  def slug
    [parent_slug, this_slug].compact.join('-')
  end

  private

    def parent_slug
      parent.slug if parent
    end

    def this_slug
      name.gsub(/[^\w]/, ' ').gsub(/\s+/, '_').downcase if name
    end

    def parent_best_colour_num
      parent.best_colour_num if parent
    end

    before_save :set_url_name
    before_create :set_url_name
    def set_url_name
      self.url_name = name.parameterize
    end
end
