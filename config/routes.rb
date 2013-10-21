Chalkle::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :chalklers, :controllers => { :omniauth_callbacks => 'chalklers/omniauth_callbacks', :registrations => 'chalklers/registrations' }

  root to: 'chalklers/dashboard#index'
  match '/beta' => 'chalklers/dashboard#beta'

  resources :channels, :only => :show do
    resources :lessons, :only => [:show, :index], :path => 'classes' do
      collection do
        get :month
        get 'month/:year/:month' => 'lessons#month', as: :specific_month
        get :week
        get 'week/:year/:month/:day' => 'lessons#week', as: :specific_week
        get :upcoming
      end
      member do
        get :beta
      end

      resources :bookings, :only => [:new, :create] do
        get :payment_callback
      end
    end
  end

  resources :bookings, :only => [:index, :show, :edit, :update] do
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
