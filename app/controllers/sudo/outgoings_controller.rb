class Sudo::OutgoingsController < Sudo::BaseController
  before_filter :load_outgoing_payment, only: [:show,:edit,:update]

  def index

  end

  def pending
    @outgoings = OutgoingPayment.where status == OutgoingPayment::STATUS_1
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