class OutgoingPaymentsController < ApplicationController
  
  before_filter :load_outgoing_payment, only: [:show]

  def index
    if params[:teacher_id].present?
      @provider_teacher = ProviderTeacher.find(params[:teacher_id]) 
      authorize(@provider_teacher, :admin?)
      @title = "Remittance Advice for #{@provider_teacher.name}"
    else
      authorize(@provider, :admin?)
      @title = "Remittance Advice for #{@provider.name}"
    end
    @outgoing_payments = (@provider_teacher || @provider).outgoing_payments.paid.order(:paid_date).reverse
  end

  def show
    if @outgoing_payment.for_teacher?
      @provider_teacher = ProviderTeacher.find(params[:teacher_id]) 
      authorize(@provider_teacher, :admin?)
      authorize(@outgoing_payment)
      render 'show_for_teacher'
    else
      authorize(@provider, :admin?)
      authorize(@outgoing_payment)
      render 'show_for_provider'
    end
  end

  private
    def load_outgoing_payment
      @outgoing_payment = OutgoingPayment.find_by_id params[:id]
      not_found and return unless @outgoing_payment
      @provider = @outgoing_payment.outgoing_provider
    end
end