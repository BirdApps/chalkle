class Sudo::OutgoingPaymentsController < Sudo::BaseController
  before_filter :load_outgoing_payment, only: [:show,:edit,:approve,:update]

  def index
    status = params[:status].present? ? params[:status] : 'pending'
    if OutgoingPayment::STATUSES.include?(status)
      @outgoings = OutgoingPayment.where(status: status)
    else
      @outgoings = OutgoingPayment.all
    end
  end

  def show
  end

  def approve
    @outgoing.approve!
    redirect_to sudo_outgoing_payment_path(@outgoing.id)
  end

  def pay
    reference = params[:ref] if params[:ref].present?
    @outgoing.mark_paid!(reference)
    redirect_to sudo_outgoing_payment_path(@outgoing.id)
  end

  def update
  end

  private
    def load_outgoing_payment
      @outgoing = OutgoingPayment.find params[:id]
    end
end