class Sudo::PartnerInquiriesController < Sudo::BaseController
  before_filter :load_enquiry, only: [:show,:edit]

  def index
    type = params[:type]
    if type=="hidden"
      @hellos = PartnerInquiry.hidden
    else
      @hellos = PartnerInquiry.visible
    end
  end

  def show

  end

  def edit
    new_status = params[:new_status]
    if new_status == 'visible'
      @hello.visible = true
    elsif new_status == 'hidden'
      @hello.visible = false
    end
    @hello.save
    redirect_to sudo_partner_inquiries_path
  end

  private
    def load_enquiry
      @hello = PartnerInquiry.find params[:id]
    end
end