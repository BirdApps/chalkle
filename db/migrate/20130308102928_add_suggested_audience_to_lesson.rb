class AddSuggestedAudienceToLesson < ActiveRecord::Migration
  def up
  	add_column :lessons, :suggested_audience, :text, :default => nil

  	Lesson.reset_column_information

    Lesson.all.each { |l| l.update_attribute :suggested_audience, nil }
  end

  def down
  	remove_column :lessons, :suggested_audience
  end
end
