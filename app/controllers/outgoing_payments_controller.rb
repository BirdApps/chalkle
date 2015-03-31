class OutgoingPaymentsController < ApplicationController
  
  before_filter :load_outgoing_payment, only: [:show]
  before_filter :load_provider, :sidebar_administrate_provider, :header_provider


  def index
    @outgoing_payments = (@provider_teacher || @provider).outgoing_payments.order(:paid_date).reverse
  end

  def show

  end

  private
    def load_outgoing_payment
      @outgoing_payment = OutgoingPayment.find_by_id params[:id]
      not_found and return unless @outgoing_payment
    end

    def load_teacher
      @provider_teacher = ProviderTeacher.find(params[:teacher_id]) if params[:teacher_id].present?
    end
end