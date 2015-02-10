class PartnersController < ApplicationController

  layout 'partners'

    # GET /partners
  def index
    @hero_text = "A complete system for delivering \n great classes in the real world."
    render 'partners'
  end

  # GET /partners/team
  def team
    @hero_text = "What does a renaissance of learning look like?"
    render 'team'
  end

  # GET /partners/say_hello
  def say_hello
    @hero_text = "Let's get connected. Say Hello!"
    @partner_inquiry = PartnerInquiry.new
    render 'say_hello'
  end

  # POST /partners/said_hello
  def said_hello

    @partner_inquiry = PartnerInquiry.new params[:said_hello]
    
    if @partner_inquiry.save
      flash[:notice] = "Thank you for your request. We will get in touch with you shortly."
      Notify.for(@partner_inquiry).created
      render 'say_hello'
    else 
      flash[:errors] = @partner_inquiry.errors.messages

      render 'say_hello'
    end



  end

end