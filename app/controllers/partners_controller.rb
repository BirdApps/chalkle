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
    render 'say_hello'
  end

  # POST /partners/said_hello
  def said_hello
    # handle the form
  end

end