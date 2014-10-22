class Sudo::OutgoingPaymentsController < Sudo::BaseController
  before_filter :load_outgoing_payment, only: [:show,:edit,:update]

  def index
    @outgoings = OutgoingPayment.all
  end

  def pending
    @outgoings = OutgoingPayment.pending
    render 'index'
  end

  def complete
    
  end

  def show
    
  end

  def new

  end

  def create

  end

  def edit

  end

  def update

  end

  private
    def load_outgoing_payment
      @outgoing = OutgoingPayment.find params[:id]
    end
end