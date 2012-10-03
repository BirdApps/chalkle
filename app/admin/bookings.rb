ActiveAdmin.register Booking do
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
    column :status
    column :guests
    column :created_at
    default_actions
  end
  
end
