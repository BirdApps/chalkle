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
    column :paid
    column :guests
    column :created_at
    default_actions
  end
    
  form do |f|
    f.inputs :details do
      f.input :lesson
      f.input :chalkler
      f.input :guests
      f.input :status, as: :select, collection: ["yes", "no", "waiting"]
      f.input :paid
    end

    f.buttons
  end
  
end
