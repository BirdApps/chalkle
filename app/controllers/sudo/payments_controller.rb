class Sudo::PaymentsController < Sudo::BaseController
  before_filter :load_payment, only: [:show]
  before_filter :set_titles
  
  def index
    @payments = Payment.by_date
  end

  def show
  end

  private
    def load_payment
      @payment = Payment.find_by_id params[:id]
    end

    def set_titles
      @page_title = "Payments"
    end
end