ActiveAdmin.register Chalkler do
  config.sort_order = "created_at_desc"

  controller do
    load_resource :except => :index
    authorize_resource

    def create
      params.delete :group_ids
      Chalkler.create(bio: params[:bio], email: params[:email], name: params[:name], gst: params[:gst], meetup_id: params[:meetup_id])
    end
  end

  filter :groups_name, :as => :select, :label => "Group",
    :collection => proc{ current_admin_user.groups.collect{ |g| [g.name, g.name] }}
  filter :meetup_id
  filter :name
  filter :email

  index do
    column :id
    column :name
    column :groups do |chalkler|
      chalkler.groups.collect{|g| g.name}.join(", ")
    end
    column :meetup_id do |chalkler|
      if chalkler.meetup_data.present?
        link_to chalkler.meetup_id, chalkler.meetup_data["link"]
      else
        "non-meetup"
      end
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
        if chalkler.meetup_data.present?
          link_to chalkler.meetup_id, chalkler.meetup_data["link"]
        else
          "non-meetup"
        end
      end
      row :email
      row :gst
      row :bio
      row :teaching do
        render partial: "/admin/chalklers/lessons", locals: { lessons: chalkler.lessons_taught }
      end
      row :lessons do
        render partial: "/admin/chalklers/lessons", locals: { lessons: chalkler.lessons }
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
      f.input :groups, :as => :check_boxes
      f.input :meetup_id
      f.input :email
      f.input :gst
      f.input :bio
    end
    f.actions
  end
end
