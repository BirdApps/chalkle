ActiveAdmin.register LessonSuggestion do

  controller do
    load_resource :except => :index
    authorize_resource

    def create
      @lesson_suggestion = LessonSuggestion.new(name: params[:lesson_suggestion][:name], description: params[:lesson_suggestion][:desctiption], category_id: params[:lesson_suggestion][:category_id])
      if @lesson_suggestion.save
        @lesson_suggestion.channel_ids = params[:lesson_suggestion][:channel_ids]
        update!
      else
        redirect_to :back
      end
    end
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

  form :partial => 'form'
end
