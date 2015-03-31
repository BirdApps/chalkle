class OutgoingPaymentsController < ApplicationController
  
  before_filter :load_outgoing_payment, only: [:show]
  before_filter :load_provider, :sidebar_administrate_provider, :header_provider


  def index
    if params[:teacher_id].present?
      @provider_teacher = ProviderTeacher.find(params[:teacher_id]) 
      authorize(@provider_teacher, :admin?)
      @title = "Remittance for #{@provider_teacher.name}"
    else
      authorize(@provider, :admin?)
      @title = "Remittance for #{@provider.name}"
    end
    @outgoing_payments = (@provider_teacher || @provider).outgoing_payments.paid.order(:paid_date).reverse
  end

  def show
    authorize @outgoing_payment
  end

  private
    def load_outgoing_payment
      @outgoing_payment = OutgoingPayment.find_by_id params[:id]
      not_found and return unless @outgoing_payment
    end
end