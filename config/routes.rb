Chalkle::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :chalklers, :controllers => { :omniauth_callbacks => 'chalklers/omniauth_callbacks', :registrations => 'chalklers/registrations' }

  root to: 'chalklers/dashboard#index'

  resources :channels, :only => :show do
    resources :lessons, :only => :show, :path => 'classes' do
      resources :bookings, :only => [:new, :create]
    end
  end

  resources :bookings, :only => [:index, :show] do
    member do
      put 'cancel'
    end
  end


  namespace :chalklers do
    root to: 'dashboard#index'
    resources :lesson_suggestions, :only => [:new, :create], :path => 'class_suggestions'

    get '/enter_email' => 'preferences#enter_email', as: 'enter_email'
    put '/enter_email' => 'preferences#enter_email', as: 'enter_email'

    match '/missing_channel' => 'dashboard#missing_channel'

    resources :teachings do
      collection do
        get 'success'
      end
    end

    get '/preferences' => 'preferences#show', as: 'preferences'
    get '/preferences/meetup_email_settings' => 'preferences#meetup_email_settings', as: 'meetup_email_settings'
    put '/preferences' => 'preferences#save', as: 'preferences'
  end

  get '/styleguide' => 'application#styleguide', as: 'styleguide'
  match '/image' => 'image#generate'
end
