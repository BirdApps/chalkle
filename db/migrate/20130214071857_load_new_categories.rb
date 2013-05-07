class LoadNewCategories < ActiveRecord::Migration
  def up
    Category.delete_all
    c = Category.new
    c.name  =  "Agriculture & Environment"
    c.save
    Category.new
    c.name  =  "Art & Handcrafts"
    c.save
    Category.new
    c.name  =  "Business & Finances"
    c.save
    Category.new
    c.name  =  "Computers & Technology"
    c.save
    Category.new
    c.name  =  "Fashion & Beauty"
    c.save
    Category.new
    c.name  =  "Film & Photography"
    c.save
    Category.new
    c.name  =  "Food & Drink"
    c.save
    Category.new
    c.name  =  "Maker & DIY"
    c.save
    Category.new
    c.name  =  "Health & Wellbeing"
    c.save
    Category.new
    c.name  =  "Language & Culture"
    c.save
    Category.new
    c.name  =  "Life Skills"
    c.save
    Category.new
    c.name  =  "Music & Performance"
    c.save
    Category.new
    c.name  =  "Societies"
    c.save
    Category.new
    c.name  =  "Science"
    c.save
    Category.new
    c.name  =  "Sports & Outdoors"
    c.save
    Category.new
    c.name  =  "What is Trending"
    c.save
    Category.new
    c.name  =  "WTF is that"
    c.save
    Category.new
    c.name  =  "Professional development"
    c.save
    Category.new
    c.name  =  "Entrepreneurship"
    c.save
  end

  def down
  end
end
