ActiveAdmin.register Channel do
  config.sort_order = "name_asc"

  controller do
    load_resource :except => :index
  end

  filter :name

  index do
    authorized? :index, Channel
    column :id
    column :name
    column :visible
    column :url_name
    column :regions do |channel|
      channel.regions.map(&:name).join(',')
    end
    default_actions
  end

  show title: :name do |channel|
    attributes_table do
      row :name
      row :url_name
      row :regions do |channel|
        channel.regions.map(&:name).join(',')
      end
      row :visible
      row :short_description
      row :description do |channel|
        simple_format channel.description
      end
      row :website_url
      row :account
      row :created_at
      row :updated_at

      row :logo do |channel|
        image_tag(channel.logo.url) if channel.logo.present?
      end
      row :photos do |channel|
        channel.photos.map do |photo|
          image_tag(photo.image.url) if photo.image.present?
        end.join(' ').html_safe
      end
    end
    active_admin_comments
  end

  form do |f|
    f.inputs :details, :multipart => true do
      f.input :name
      f.input :url_name
      f.input :regions, include_blank: true
      f.input :visible
      f.input :short_description
      f.input :description
      f.input :website_url
      f.input :account, label: "Bank account number"

      f.input :logo
      f.has_many :photos do |photo|
        photo.inputs "Photos" do
          photo.input :image
        end
      end
    end
    f.buttons
  end
end
