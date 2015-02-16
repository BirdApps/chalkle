class AddSearchableToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :searchable, :text
    Course.reset_column_information
    total = Course.count
    Course.transaction do
      count = 0
      errors = ""
      latest_error = 100.years.ago
      Course.scoped.each do |course|
        if course.build_searchable!
          count+=1
        else
          errors += "#{course.id} "
          date = course.start_at || course.created_at
          latest_error = date if date > latest_error
        end
      end
      puts "#{count} of #{total} searchable calculated"
      puts "the following courses could not save, the latest of which was scheduled for #{latest_error}: #{errors}" if count != total
    end
  end
end
