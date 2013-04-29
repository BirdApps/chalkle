ActiveAdmin.register LessonSuggestion do

  controller do
    load_resource :except => :index
    authorize_resource

    def create
      if params[:lesson_suggestion][:join_channels]
        params[:lesson_suggestion][:join_channels].reject!(&:empty?)
      end
      @lesson_suggestion = LessonSuggestion.new(params[:lesson_suggestion], :as => :admin)
      if current_admin_user.channels.count == 1
        @lesson_suggestion.join_channels = [ current_admin_user.channel_ids ]
      end
      create!
    end
  end

  filter :channels_name, :as => :select, :label => "Channel",
    :collection => proc{ current_admin_user.channels.collect{ |c| [c.name, c.name] }}
  filter :name
  filter :category
  filter :chalkler

  index do
    column :id
    column :name
    column :channels do |lesson_suggestion|
      lesson_suggestion.channels.collect{ |c| c.name}.join(", ")
    end
    column :category
    column :chalkler
    column :description
    column :created_at
    default_actions
  end

  show title: :name do |lesson_suggestion|
    attributes_table do
      row :name
      row :channels do |lesson|
        lesson_suggestion.channels.collect{ |c| c.name}.join(", ")
      end
      row :chalkler
      row :category
      row :description
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  form do |f|
    f.inputs :details do
      f.input :name
      f.input :category
      f.input :chalkler, :label => 'Suggested by'
      if current_admin_user.channels.size > 1
        if f.object.new_record?
          f.input :join_channels, :label => 'Channels', :as => :check_boxes, :collection => current_admin_user.channels
        else
          f.input :channels, :as => :check_boxes, :label => 'Channels'
        end
      end
      f.input :description
    end
    f.actions
  end

end
