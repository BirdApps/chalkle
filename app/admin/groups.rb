ActiveAdmin.register Group do
  menu :if => proc{ can?(:manage, AdminUser) }
  controller.authorize_resource

  config.sort_order = "name_asc"

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
      row :api_key
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end
end