ActiveAdmin.register PartnerInquiry do 
  config.sort_order = "created_at_desc"


  controller do
    load_resource :except => :index
    authorize_resource
  end


end
