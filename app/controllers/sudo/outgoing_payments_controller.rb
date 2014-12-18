class Sudo::OutgoingPaymentsController < Sudo::BaseController

  before_filter :load_outgoing_payment, only: [:show,:edit,:approve,:update,:pay]

  def index
    status = params[:status].present? ? params[:status] : 'pending'
    if OutgoingPayment::STATUSES.include? status
      @outgoings = OutgoingPayment.by_date.where(status: status).valid
    else
      @outgoings = OutgoingPayment.by_date.valid
    end 
  end

  def show
    @outgoing.recalculate! if params[:recalculate].present?
    @page_title = @outgoing.for_teacher? ? "Teacher Payment" : "Provider Payment"
  end

  def approve
    @outgoing.approve!
    redirect_to sudo_outgoing_payment_path(@outgoing)
  end

  def pay
    reference = params[:outgoing_payment][:reference] if params[:outgoing_payment][:reference].present?
    @outgoing.mark_paid!(reference)
    redirect_to sudo_outgoing_payment_path(@outgoing)
  end

  def update
  end

  private
    def load_outgoing_payment
      @outgoing = OutgoingPayment.find params[:id]
    end
end