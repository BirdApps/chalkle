class PartnersController < ApplicationController

    # GET /partners
  def index
    @page_subtitle = "How does it all work?"
    @page_title = "About Chalkle"
    @hero_text = "A complete system for delivering \n great classes in the real world."
  end

  # GET /partners/team
  def team
    @page_subtitle = "The wizards who make it happen"
    @page_title = "The Team"
    @hero_text = "What does a renaissance of learning look like?"
    render 'team'
  end

  # GET /partners/say_hello
  def say_hello
    @page_subtitle = "Contact Chalkle"
    @page_title = "Let's get connected. Say Hello!"
    @partner_inquiry = PartnerInquiry.new
    render 'say_hello'
  end

  # POST /partners/said_hello
  def said_hello
    @page_subtitle = "Contact Chalkle"
    @page_title = "Let's get connected. Say Hello!"
    @partner_inquiry = PartnerInquiry.new params[:partner_inquiry]
    
    if @partner_inquiry.save
      flash[:notice] = "Thank you for your request. We will get in touch with you shortly."
      Notify.for(@partner_inquiry).created
      @partner_inquiry = PartnerInquiry.new
      render 'say_hello'
    else 
      flash[:errors] = @partner_inquiry.errors.messages
      render 'say_hello'
    end

  end

end