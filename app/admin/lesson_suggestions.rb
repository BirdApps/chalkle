ActiveAdmin.register LessonSuggestion do

  controller do
    load_resource :except => :index
    authorize_resource
  end

  filter :name

  index do
    column :id
    column :name
    column :description
    column :channels do |lesson_suggestion|
      lesson_suggestion.channels.collect{ |c| c.name}.join(", ")
    end
    column :category
    default_actions
  end

  show title: :name do |lesson_suggestion|
    attributes_table do
      row :name
      row :description
      row :channels do |lesson|
        lesson_suggestion.channels.collect{ |c| c.name}.join(", ")
      end
      row :category
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end
end
