ActiveAdmin.register Channel do
  config.sort_order = "name_asc"

  controller do
    load_resource :except => :index
    authorize_resource
  end

  index do
    column :id
    column :name
    column :visible
    column :url_name
    column :channel_percentage do |channel|
      number_to_percentage(channel.channel_percentage*100, :precision => 2)
    end
    column :teacher_percentage do |channel|
      number_to_percentage(channel.teacher_percentage*100, :precision => 2)
    end
    default_actions
  end

  show title: :name do |channel|
    attributes_table do
      row :name
      row :url_name
      row :visible
      row :logo do |channel|
        image_tag(channel.logo.url) if channel.logo
      end
      row :description
      row :website_url
      row "Percentage of revenue going to channel" do |channel|
        number_to_percentage(channel.channel_percentage*100, :precision => 2)
      end
      row "Percentage of revenue going to teacher" do |channel|
        number_to_percentage(channel.teacher_percentage*100, :precision => 2)
      end
      row :account
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  form do |f|
    f.inputs :details, :multipart => true do
      f.input :name
      f.input :url_name
      f.input :visible
      f.input :logo
      f.input :description
      f.input :website_url
      f.input :channel_percentage, label: "Percentage of revenue going to channel"
      f.input :teacher_percentage, label: "Percentage of revenue going to teacher"
      f.input :account, label: "Bank account number"
    end
    f.buttons
  end
end
