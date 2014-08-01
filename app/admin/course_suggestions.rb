ActiveAdmin.register CourseSuggestion do

  controller do
    load_resource :except => :index

    def create
      if params[:course_suggestion][:join_channels]
        params[:course_suggestion][:join_channels].reject!(&:empty?)
      end
      @course_suggestion = CourseSuggestion.new(params[:course_suggestion], :as => :admin)
      if current_admin_user.channels.count == 1
        @course_suggestion.join_channels = [ current_admin_user.channel_ids ]
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
    authorized? :index, CourseSuggestion
    column :id
    column :name
    column :channels do |course_suggestion|
      course_suggestion.channels.collect{ |c| c.name}.join(", ")
    end
    column :category
    column :chalkler
    column :description
    column :created_at
    default_actions
  end

  show title: :name do |course_suggestion|
    attributes_table do
      row :name
      row :channels do |course|
        course_suggestion.channels.collect{ |c| c.name}.join(", ")
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
