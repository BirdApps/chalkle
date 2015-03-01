class PartnersController < ApplicationController
  before_filter :header_partners

  # GET /partners
  def index
    @page_title = "About Chalkle"
    @hero_text = "A complete system for delivering \n great classes in the real world."
  end

  # GET /partners/team
  def team
    @page_title = "The Team"
    @hero_text = "What does a renaissance of learning look like?"
    render 'team'
  end

  # GET /partners/say_hello
  def say_hello
    @page_title = "Let's get connected. Say Hello!"
    @partner_inquiry = PartnerInquiry.new
    render 'say_hello'
  end

  # POST /partners/said_hello
  def said_hello
    @page_title = "Let's get connected. Say Hello!"
    @partner_inquiry = PartnerInquiry.new params[:partner_inquiry]
    
    if @partner_inquiry.save
      add_flash :success, "Thank you for your request. We will get in touch with you shortly."
      Notify.for(@partner_inquiry).created
      @partner_inquiry = PartnerInquiry.new
      render 'say_hello'
    else 
      flash_errors @partner_inquiry.errors
      render 'say_hello'
    end

  end

  private

    def header_partners
      @nav_links = [{
        img_name: "bolt",
        link: partners_path,
        active: request.path.include?("index"),
        title: "About Chalkle"
      },{
        img_name: "people",
        link: partners_team_path,
        active: request.path.include?("team"),
        title: "The Team"
      },{
        img_name: "contact",
        link: partners_say_hello_path,
        active: request.path.include?("say_hello") || request.path.include?("said_hello"),
        title: "Contact"
      }]
    end
end