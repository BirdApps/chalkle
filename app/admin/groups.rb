ActiveAdmin.register Group do
  config.sort_order = "name_asc"

  controller do
    load_resource :except => :index
    authorize_resource
  end

  index do
    column :id
    column :name
    column :url_name
    default_actions
  end

  show title: :name do |group|
    attributes_table do
      row :name
      row :url_name
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end
end