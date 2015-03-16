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

  match 'teach' => 'courses#teach'
  match 'learn' => redirect("/discover")
  match 'discover' => 'courses#index'

  get 'c/:id' => 'courses#show', as: :tiny_course
  post 'bookings/lpn', as: :lpn, to: 'bookings#lpn'
  get 'bookings/payment_callback/:booking_ids', as: :payment_callback, to: 'bookings#payment_callback'

  get '/styleguide' => 'application#styleguide', as: 'styleguide'
  get 'chalklers' => redirect("/")

  get 'classes/fetch', to: 'courses#fetch'
  get 'url_available/:url_name', to: 'providers#url_available'

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
        post 'overview'
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
      collection do 
        get 'pending'
        get 'complete'
      end
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
    get 'say_hello', to: 'partners#said_hello', as: 'said_hello'
  end

  get 'classes/new', to: 'courses#choose_provider', as: :new_course  
  match 'classes/calculate_cost', to: 'courses#calculate_cost'
  get 'classes/:id', to: 'courses#show', as: :old_course_path #backwards compatibility2

  resources :providers, only: [:index, :create, :new]
  resource :provider, except: [:new, :create], path: ':provider_url_name' do
    match '', to: 'providers#show'
    
    get 'metrics', to: 'providers#metrics'
    get 'contact', to: 'providers#contact'
    post 'contact', to: 'providers#contact'

    get 'fetch', to: 'courses#fetch'
    
    get 'edit'
    put 'edit', to: 'providers#update'

    resources :subscriptions, only: [:index, :create, :destroy], path: 'followers'
    resources :bookings, only: [:index, :show]
    resources :provider_teachers, path: 'teachers', as: 'teachers'
    resources :provider_admins, path: 'admins', as: 'admins'

    get ':course_url_name', to: 'courses#series', as: :course_series

    resources :classes, only: [:new, :create], controller: :courses
    resource :course, except: [:new, :create], path: ':course_url_name/:course_id' do
      member do 
        get 'cancel',         to: 'courses#cancel'
        put 'cancel',         to: 'courses#confirm_cancel'
        post 'clone',          to: 'courses#clone'
        post 'change_status',  to: 'courses#change_status'
      end
      resources :course_notices, as: :notices, path: 'discussion'

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

  # get '/partners' => 'partners#index'
  # #get '/partners/pricing' => 'partners#pricing'
  # get '/partners/team' => 'partners#team'
  # get '/partners/say_hello' => 'partners#say_hello'
  # post '/partners/say_hello' =>'partners#said_hello', as: 'said_hello', controller: 'partners'

  #TODO: find an easier way of doing these provider routes!
  #get ':provider_url_name/admins', to: 'providers#admins', as: :providers_admins
  #get ':provider_url_name/admins/new', to: 'provider_admins#new', as: :new_provider_admin
  #get ':provider_url_name/admin/:id/edit', to: 'provider_admins#edit', as: :edit_provider_admin
  
  #get 'provider_url_name/metrics', to: 'providers#metrics', as: :provider_metrics

  #get 'providers/:provider_id/url_available/:url_name', to: 'providers#url_available', as: :provider_url_available
  #get ':provider_url_name/teachers', to: 'providers#teachers', as: :providers_teachers
  #get 'providers/:provider_id/teachers', to: 'providers#teachers', as: :provider_provider_teachers
  #get ':provider_url_name/teachers/new', to: 'provider_teachers#new', as: :new_provider_teacher
  #get ':provider_url_name/teacher/:id', to: 'provider_teachers#show', as: :provider_provider_teacher
  #get ':provider_url_name/teacher/:id', to: 'provider_teachers#show', as: :provider_teacher
  #get ':provider_url_name/settings', to: 'providers#edit', as: :provider_settings
  #put ':provider_url_name/settings', to: 'providers#update', as: :provider_settings
  #get ':provider_url_name/bookings', to: 'providers#bookings', as: :provider_bookings
  #get ':provider_url_name/contact', to: 'providers#contact', as: :provider_contact
  #post ':provider_url_name/contact', to: 'providers#contact', as: :provider_contact
  #get ':provider_url_name/follower/:chalkler_id', to: 'providers#follower', as: :provider_follower
  #get ':provider_url_name/followers', to: 'providers#followers', as: :provider_followers
  #get ':provider_url_name/:course_url_name', to: 'providers#series', as: :provider_course_series
  #get '*provider_url_name/*course_url_name/:id', to: 'courses#show', as: :provider_course
  #get ':provider_url_name', to: 'providers#show', as: :provider

    # resources :providers, path: 'providers', only: [:index, :teachers, :new, :create] do
  #   resources :subscriptions, only: [:create, :destroy], path: 'follow'

  # end
end