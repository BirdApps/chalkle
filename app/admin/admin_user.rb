ActiveAdmin.register AdminUser do
  menu :if => proc{ can?(:manage, AdminUser) }
  controller.authorize_resource

  config.sort_order = "email_asc"

  index do
    column :id
    column :name
    column :groups do |admin_user|
      admin_user.groups.collect{|g| g.name}.join(", ")
    end
    column :email
    column :role
    default_actions
  end

  show do |admin_user|
    attributes_table do
      row :name
      row :email
      row :role
      row :groups do
        raw admin_user.groups.collect{ |g| link_to g.name, admin_group_path(g)}.join(", ")
      end
    end
    active_admin_comments
  end

  form do |f|
    f.inputs "Admin User Details" do
      f.input :name
      f.input :email
      f.input :groups, :as => :check_boxes
      f.input :role, :as => :select, :collection => ["super"]
    end
    f.buttons
  end
end
