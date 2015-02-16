require 'routing_constraints'
Chalkle::Application.routes.draw do

  #ActiveAdmin.routes(self)

  match '(*any)' => redirect { |p, req| req.url.sub!('my.', '') } , :constraints => { :host => /^my\./ }
  match '(*any)' => redirect { |p, req| req.url.sub!('www.', '') } , :constraints => { :host => /^www\./ }

  devise_for :chalklers, controllers: { omniauth_callbacks: 'people/omniauth_callbacks', registrations: 'people/registrations', invitations: 'invitations' }
  
  constraints(Subdomain) do
    match '/' => 'providers#show'
  end

  root to: 'courses#index'
  
  get '/about' => 'application#about', as: :about

  get '/terms' => 'terms#chalkler', as: :terms

  get '/privacy' => 'terms#privacy', as: :privacy

  get '/terms/provider' => 'terms#provider', as: :provider_terms

  get '/terms/teacher' => 'terms#teacher', as: :teacher_terms


  resources :provider_teachers, path: 'teachers', except: [:new, :show, :index]

  resources :provider_admins, path: 'admins', except: [:new, :show, :index] 

  resources :provider_plans, path: 'plans'

  match '/teach' => 'courses#teach'
  match '/learn' => 'courses#learn'


  resources :courses, path: 'classes' do

    member do
      get 'cancel', to: 'courses#cancel', as: :cancel
      get 'clone'
      put 'cancel', to: 'courses#confirm_cancel', as: :cancel
      put 'change_status', to: 'courses#change_status', as: :change_status
    end

    resource :course_notices, path: 'discussion' do 
      get 'show/:id', to: 'course_notices#show', as: :show
      put 'update/:id', to: 'course_notices#update', as: :update
      post 'create', to: 'course_notices#create', as: :create
      get 'delete/:id', to: 'course_notices#destroy', as: :delete
    end
    
    resources :bookings, only: [:index, :show, :new, :create] do
      get :payment_callback
      collection { get 'csv' }
      member do
        get 'take_rights'
        get 'cancel'
        put 'cancel', to: 'bookings#confirm_cancel', as: :cancel
      end
    end

    collection do
      get 'calculate_cost'
      get 'mine'
      post 'fetch'
    end
    
  end

  get '/c/:id' => 'courses#show', as: :course_tiny
  post '/bookings/lpn', as: :lpn
  namespace :me do
    
    root to: 'dashboard#index'

    get '/notifications' => 'notifications#index', as: :notifications
    get '/notifications/list' => 'notifications#list', as: :list_notifications
    get '/notifications/count' => 'notifications#list', as: :count_notifications
    get '/notifications/seen' => 'notifications#seen', as: :seen_notifications
    get '/notification/:id' => 'notifications#show', as: :show_notification

    get '/bookings' => 'dashboard#bookings', as: :bookings
    
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

  resources :chalklers, path: 'people', only: [:index, :show] do
    resources :notifications, only: [:index, :show]
    collection do
      post 'exists'
      post 'set_location'
      get 'get_location' 
    end
  end

  resources :providers, path: 'providers', only: [:index, :teachers, :new, :create] do
    resources :subscriptions, only: [:create, :destroy], path: 'follow'
  end

  get '/styleguide' => 'application#styleguide', as: 'styleguide'
  #match '/image' => 'image#generate'
  get 'chalklers' => redirect("/")

  %w(blog).each do |name|
#  %w(welcome about blog learn).each do |name|
    match "/#{name}" => redirect("http://blog.chalkle.com/#{name}"), :as => name.to_sym
  end


  get '/partners' => 'partners#index'
  #get '/partners/pricing' => 'partners#pricing'
  get '/partners/team' => 'partners#team'
  get '/partners/say_hello' => 'partners#say_hello'
  post '/partners/say_hello' =>'partners#said_hello', as: 'said_hello', controller: 'partners'

  get 'resources', to: 'resources#index', as: :resources
  get 'metrics', to: 'metrics#index', as: :metrics

  #TODO: find an easier way of doing these provider routes!
  get ':provider_url_name/admins', to: 'providers#admins', as: :providers_admins
  get 'providers/:provider_id/admins', to: 'providers#admins', as: :provider_provider_admins
  get ':provider_url_name/admins/new', to: 'provider_admins#new', as: :new_provider_admin
  get ':provider_url_name/admin/:id/edit', to: 'provider_admins#edit', as: :edit_provider_admin
  
  get 'providers/:provider_id/url_available/:url_name', to: 'providers#url_available', as: :provider_url_available
  get ':provider_url_name/teachers', to: 'providers#teachers', as: :providers_teachers
  get 'providers/:provider_id/teachers', to: 'providers#teachers', as: :provider_provider_teachers
  get ':provider_url_name/teachers/new', to: 'provider_teachers#new', as: :new_provider_teacher
  get ':provider_url_name/teacher/:id', to: 'provider_teachers#show', as: :provider_provider_teacher
  get ':provider_url_name/teacher/:id', to: 'provider_teachers#show', as: :provider_teacher
  get ':provider_url_name/settings', to: 'providers#edit', as: :provider_settings
  put ':provider_url_name/settings', to: 'providers#update', as: :provider_settings
  get ':provider_url_name/contact', to: 'providers#contact', as: :provider_contact
  post ':provider_url_name/contact', to: 'providers#contact', as: :provider_contact
  get ':provider_url_name/followers', to: 'providers#followers', as: :provider_followers
  get ':provider_url_name/:course_url_name', to: 'providers#series', as: :provider_course_series
  get '*provider_url_name/*course_url_name/:id', to: 'courses#show', as: :provider_course
  get ':provider_url_name', to: 'providers#show', as: :provider

  match '*a', :to => 'application#not_found'
end
