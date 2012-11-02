ActiveAdmin.register Chalkler do
  controller do
    load_and_authorize_resource :except => :index
    def scoped_collection
      end_of_association_chain.accessible_by(current_ability)
    end
  end

  config.sort_order = "created_at_desc"

  filter :groups_name, :as => :select, :label => "Group",
    :collection => proc{ current_admin_user.groups.collect{ |g| [g.name, g.name] }}
  filter :name
  filter :meetup_id
  filter :email

  index do
    column :id
    column :name
    column :groups do |chalkler|
      chalkler.groups.collect{|g| g.name}.join(", ")
    end
    column :meetup_id do |chalkler|
      link_to chalkler.meetup_id, chalkler.meetup_data["link"]
    end
    column :email
    column :bio
    column :created_at
    default_actions
  end
  show title: :name do |chalkler|
    attributes_table do
      row :name
      row :id
      row :meetup_id do
        link_to chalkler.meetup_id, chalkler.meetup_data["link"]
      end
      row :email
      row :bio
      row :teaching do
        raw chalkler.lessons_taught.collect{|l| link_to "#{l.name} - #{l.start_at}", admin_class_path(l)}.join('<br/> ')
      end
      row :lessons do
        raw chalkler.lessons.collect{|l| link_to "#{l.name} - #{l.start_at}", admin_class_path(l)}.join('<br/> ')
      end
      row :meetup_data
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  form do |f|
    f.inputs :details do
      f.input :name
      f.input :meetup_id
      f.input :email
      f.input :bio
    end

    f.buttons
  end

end
