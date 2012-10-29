ActiveAdmin.register Booking do
  config.sort_order = "created_at_desc"
  controller do
    def scoped_collection
      Booking.where(status: "yes")
    end
  end
  index do
    column :id
    column :lesson
    column :chalkler
    column :cost
    column :paid
    column :guests
    column :created_at
    default_actions
  end

  show do
    attributes_table do
      row :id
      row :lesson
      row :chalkler
      row :status
      row :guests
      row :cost
      row :paid
      row :meetup_data
      row :created_at
      row :updated_at

    end
    active_admin_comments

  end
    
  form do |f|
    f.inputs :details do
      f.input :lesson
      f.input :chalkler
      f.input :cost
      f.input :guests
      f.input :status, as: :select, collection: ["yes", "no", "waiting"]
      f.input :paid
    end

    f.buttons
  end
  
end
