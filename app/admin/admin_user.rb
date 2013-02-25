ActiveAdmin.register AdminUser do
  config.sort_order = "email_asc"

  controller do
    load_resource :except => :index
    authorize_resource

    def create
      @admin_user = AdminUser.new(email: params[:admin_user][:email], role: params[:admin_user][:role], name: params[:admin_user][:name])
      if @admin_user.save
        update!
      else
        redirect_to :back
      end
    end
  end

  index do
    column :id
    column :name
    column :channels do |admin_user|
      admin_user.channels.collect{|c| c.name}.join(", ")
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
      row :channels do
        raw admin_user.channels.collect{ |c| link_to c.name, admin_channel_path(c)}.join(", ")
      end
    end
    active_admin_comments
  end

  form do |f|
    f.inputs "Admin User Details" do
      f.input :name
      f.input :email
      f.input :channels, :as => :check_boxes
      f.input :role, :as => :select, :collection => ["super", "channel admin"]
    end
    f.actions
  end
end
