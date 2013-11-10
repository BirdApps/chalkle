module CategoriesHelper
  def category_image(owner, size = 150)
    category = owner.category
    if category
      image_tag(
        "categories/#{size}/#{category.slug}.png",
        alt: category.name,
        title: category.name,
        class: 'category_image'
      )
    end
  end
end