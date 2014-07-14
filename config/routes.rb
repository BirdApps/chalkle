require 'routing_constraints'

Chalkle::Application.routes.draw do

  ActiveAdmin.routes(self)

  match '(*any)' => redirect { |p, req| req.url.sub!('my.', '') } , :constraints => { :host => /^my\./ }
  match '(*any)' => redirect { |p, req| req.url.sub!('www.', '') } , :constraints => { :host => /^www\./ }

  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :chalklers, controllers: { omniauth_callbacks: 'chalklers/omniauth_callbacks', registrations: 'chalklers/registrations' }
  
  constraints(Subdomain) do
    match '/' => 'channels#show'
  end

  constraints(MainDomain) do
    get ':country_code/:region_name', to: 'courses#index', constraints: {country_code: /[a-zA-Z]{2}/}
  end

  authenticated :chalkler do
    root :to => "courses#index"
  end
  root to: 'chalklers/dashboard#index'

  resources :filters, only: [:update, :destroy] do
    collection do
      put :update_view
      delete :clear
    end
  end

  resources :courses, only: [:show, :index], path: 'classes' do
    resource :regions do
    end
    collection do
      get :month, shallow: true
      get 'month/:year/:month' => 'courses#month', as: :specific_month
      get :week
      get 'week/:year/:month/:day' => 'courses#week', as: :specific_week
      get :calculate_cost
    end
  end

  resources :channels, only: :show do
    resource :subscriptions, only: [:create, :destroy] do
    end
    resources :courses, only: [:show, :index], path: 'classes' do
      collection do
        get :month, shallow: true
        get 'month/:year/:month' => 'courses#month', as: :specific_month
        get :week
        get 'week/:year/:month/:day' => 'courses#week', as: :specific_week
      end

      resources :bookings, only: [:new, :create] do
        get :payment_callback
      end
    end
  end

  resources :bookings, only: [:index, :show, :edit, :update] do
    member do
      put 'cancel'
    end
  end

  namespace :chalklers do
    root to: 'dashboard#index'
    resources :course_suggestions, only: [:new, :create], path: 'class_suggestions'

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

    delete '/preferences/destroy_chalkler/:id' => 'preferences#destroy', as: 'delete'

    get  '/data_collection/:action', as: 'data_collection', controller: 'data_collection_form'
    post '/data_collection/:action', as: 'data_collection_update', controller: 'data_collection_form'
  end

  get '/styleguide' => 'application#styleguide', as: 'styleguide'
  match '/image' => 'image#generate'

  %w(welcome about blog learn).each do |name|
    match "/#{name}" => redirect("http://blog.chalkle.com/#{name}"), :as => name.to_sym
  end

  get '/partners' => 'partners#index'
  get '/partners/pricing' => 'partners#pricing'
  get '/partners/team' => 'partners#team'
  get '/partners/say_hello' => 'partners#say_hello'
  post '/partners/said_hello', as: 'said_hello', controller: 'partners'

end
