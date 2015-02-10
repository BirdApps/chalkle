class ChangeCourseCustomRadioFieldsToCustomSelectFields < ActiveRecord::Migration
  def up
    Course.transaction do
      Course.where("custom_fields IS NOT NULL").each do |course|
        if course.custom_fields.is_a? Array
          course.custom_fields.each do |field|
            field[:type] = "select" if field[:type] == "radio_buttons"
          end
          course.save
        end
      end
    end
  end

  def down
    Course.transaction do
      Course.where("custom_fields IS NOT NULL").each do |course|
        if course.custom_fields.is_a? Array
          course.custom_fields.each do |field|
            field[:type] = "radio_buttons" if field[:type] == "select"
          end
          course.save
        end
      end
    end
  end
end
