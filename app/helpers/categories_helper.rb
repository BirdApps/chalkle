module CategoriesHelper
  def category_image(owner, size = 150)
    if owner.category
      image_tag "categories/#{size}/#{owner.category.slug}.png"
    end
  end
end