ActiveAdmin.register AdminUser do
  config.sort_order = "email_asc"

  scope :super

  index do
    column :id
    column :name
    column :email
    column :super
    default_actions
  end

  show do |admin_user|
    attributes_table do
      row :name
      row :email
      row :super
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
      f.input :super, :label => "Has global admin rights"
    end
    f.buttons
  end
end
