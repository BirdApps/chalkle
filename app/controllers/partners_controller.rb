class PartnersController < ApplicationController

  layout 'partners'

    # GET /partners
  def index
    @hero_text = "A complete system for delivering \n great classes in the real world."
    render 'partners'
  end

  # GET /partners/pricing
  def pricing
    render 'pricing'
  end

  # GET /partners/team
  def team
    render 'team'
  end

  # GET /partners/say_hello
  def say_hello
    render 'say_hello'
  end

  # POST /partners/said_hello
  def said_hello
    # handle the form
  end

end