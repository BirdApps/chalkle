class LoadNewCategories < ActiveRecord::Migration
  def up
  	Category.delete_all
  	Category.create(:name  =>  "Agriculture & Environment")
	Category.create(:name  =>  "Art & Handcrafts")
	Category.create(:name  =>  "Business & Finances")
	Category.create(:name  =>  "Computers & Technology")
	Category.create(:name  =>  "Fashion & Beauty")
	Category.create(:name  =>  "Film & Photography")
	Category.create(:name  =>  "Food & Drink")
	Category.create(:name  =>  "Maker & DIY")
	Category.create(:name  =>  "Health & Wellbeing")
	Category.create(:name  =>  "Language & Culture")
	Category.create(:name  =>  "Life Skills")
	Category.create(:name  =>  "Music & Performance")
	Category.create(:name  =>  "Societies")
	Category.create(:name  =>  "Science")
	Category.create(:name  =>  "Sports & Outdoors")
	Category.create(:name  =>  "What is Trending")
	Category.create(:name  =>  "WTF is that")
	Category.create(:name  =>  "Professional development")
	Category.create(:name  =>  "Entrepreneurship")
  end

  def down
  end
end
