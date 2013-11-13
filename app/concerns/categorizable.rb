module Categorizable
  extend ActiveSupport::Concern

  def set_category(name)
    return unless name.include?(':')
    parts = name.split(':')
    c = Category.find_by_name parts[0]
    self.category = c unless (c.nil? || category == c)
  end

  def category_name
    category.name if category
  end
end