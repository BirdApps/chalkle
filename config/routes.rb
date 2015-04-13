require 'routing_constraints'
Chalkle::Application.routes.draw do

  match '(*any)' => redirect { |p, req| req.url.sub!('my.', '') } , :constraints => { :host => /^my\./ }
  match '(*any)' => redirect { |p, req| req.url.sub!('www.', '') } , :constraints => { :host => /^www\./ }

  devise_for :chalklers, path: 'people', controllers: { omniauth_callbacks: 'people/omniauth_callbacks', registrations: 'people/registrations', invitations: 'invitations' }
  
  constraints(Subdomain) do
    match '/' => 'providers#show'
  end

  %w(blog).each do |name|
    #  %w(welcome about blog learn).each do |name|
    match "/#{name}" => redirect("http://blog.chalkle.com/#{name}"), :as => name.to_sym
  end

  root to: 'application#home'

  get 'color_scheme', to: 'application#color_scheme'

  put 'set_redirect', to: 'application#set_redirect'

  get 'terms' => 'terms#chalkler', as: :terms
  get 'privacy' => 'terms#privacy', as: :privacy
  get 'terms/provider' => 'terms#provider', as: :provider_terms
  get 'terms/teacher' => 'terms#teacher', as: :teacher_terms

  match 'teach' => 'application#teach'
  match 'learn' => redirect("/classes")

  get 'c/:id' => 'courses#show', as: :tiny_course
  match 'bookings/lpn', as: :lpn, to: 'bookings#lpn'
  get 'bookings/payment_callback/:booking_ids', as: :payment_callback, to: 'bookings#payment_callback'

  get '/styleguide' => 'application#styleguide', as: 'styleguide'
  get 'chalklers' => redirect("/")
  get 'contact' => redirect("/chalkle/say_hello")
  get 'about' => redirect("/chalkle/about")


  match 'classes', to: 'courses#index'
  match 'classes/calculate_cost', to: 'courses#calculate_cost'
  get 'classes/new', to: 'courses#choose_provider', as: :new_course  
  get 'classes/fetch', to: 'courses#fetch'
  get 'classes/:id', to: 'courses#show', as: :old_course_path #backwards compatibility2
  get 'url_available/:url_name', to: 'providers#url_available'

  get 'providers/fetch', to: 'providers#fetch'
  get 'providers/featured', to: 'providers#featured'

  resources :provider_plans, path: 'plans'

  resources :chalklers, path: 'people', only: [:index, :show] do
    member do
      get 'preferences'
      get 'bookings'
      get 'teaching'
    end

    resources :notifications, only: [:index, :show]
    collection do
      post 'exists'
      post 'set_location'
      get 'get_location' 
    end
  end

  namespace :me do
    root to: 'dashboard#index'

    get '/notifications' => 'notifications#index', as: :notifications
    get '/notifications/list' => 'notifications#list', as: :list_notifications
    get '/notifications/count' => 'notifications#list', as: :count_notifications
    get '/notifications/seen' => 'notifications#seen', as: :seen_notifications
    get '/notification/:id' => 'notifications#show', as: :show_notification
    

    post '/preferences/sidebar_open' => 'preferences#sidebar_open', as: :sidebar_open
    get '/preferences' => 'preferences#show', as: :preferences
    put '/preferences' => 'preferences#update', as: :preferences
    
    get '/enter_email' => 'preferences#enter_email', as: :enter_email
    put '/enter_email' => 'preferences#enter_email', as: :enter_email
    
    get '/preferences/notifications' => 'preferences#notifications', as: :notification_preference
    put '/preferences/notifications' => 'preferences#update_notifications', as: :notification_preference
  end

  namespace :sudo do
    root to: 'metrics#index'
    
    resources :metrics, only: :index do
      collection do
        match 'overview'
      end
    end

    resources :partner_inquiries, path: 'hellos', only: [:index,:show,:edit]
    
    resources :payments

    resources :chalklers do
      member do
        post 'become' => 'chalklers#become'
      end

      collection do
        get 'notifications'
        get 'csv'
      end
    end
    
    resources :outgoing_payments, path: 'outgoings' do
      member do
        get 'approve'
        put 'pay'
      end
    end

    resources :bookings do
      member do
        get 'set_status'
        get 'refund'
      end
    end
  end

  namespace :chalkle do
    root to: 'partners#index'
    get 'about', to: 'partners#index'
    get 'team', to: 'partners#team'
    get 'say_hello', to: 'partners#say_hello'
    post 'say_hello', to: 'partners#said_hello', as: 'said_hello'
  end

  resources :providers, only: [:index, :create, :new]

  resource :provider, except: [:new, :create], path: ':provider_url_name' do
    match '', to: 'providers#show'
    get 'about'
    get 'metrics'
    match 'contact', to: 'providers#contact'
    get 'fetch', to: 'courses#fetch'    
    get 'edit'
    put 'edit', to: 'providers#update'

    get 'bookings'

    resources :subscriptions, only: [:index, :create, :destroy], path: 'followers'
#    resources :bookings, only: [:index, :show]
    resources :provider_admins, path: 'admins', as: 'admins'

    resources :outgoing_payments, path: 'remittance', as: 'outgoings', only: [:index, :show]

    resources :provider_teachers, path: 'teachers', as: 'teachers' do
      member do 
        get 'fetch', to: 'courses#fetch'
      end
      resources :outgoing_payments, path: 'remittance', as: 'outgoings', only: [:index, :show]
    end

    get ':course_url_name', to: 'courses#series', as: :course_series

    resources :classes, only: [:new, :create], controller: :courses
    resource :course, except: [:new, :create], path: ':course_url_name/:course_id' do
      member do 
        get 'cancel',         to: 'courses#cancel'
        put 'cancel',         to: 'courses#confirm_cancel'
        post 'clone',          to: 'courses#clone'
        post 'change_status',  to: 'courses#change_status'
      end
      resources :course_notices, as: :notices, path: 'discussions'

      resources :bookings, only: [:index, :show, :new, :create] do
        collection do
          get :csv
          get :declined
        end
        member do
          get 'take_rights'
          get 'cancel'
          put 'cancel', to: 'bookings#confirm_cancel', as: :cancel
        end
      end

    end


  end

 
  match '*a', :to => 'application#not_found'

end