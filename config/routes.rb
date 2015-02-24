require 'routing_constraints'
Chalkle::Application.routes.draw do

  #ActiveAdmin.routes(self)

  match '(*any)' => redirect { |p, req| req.url.sub!('my.', '') } , :constraints => { :host => /^my\./ }
  match '(*any)' => redirect { |p, req| req.url.sub!('www.', '') } , :constraints => { :host => /^www\./ }

  devise_for :chalklers, controllers: { omniauth_callbacks: 'people/omniauth_callbacks', registrations: 'people/registrations', invitations: 'invitations' }
  
  constraints(Subdomain) do
    match '/' => 'channels#show'
  end

  root to: 'courses#index'
  
  get '/about' => 'application#about', as: :about

  get '/terms' => 'terms#chalkler', as: :terms

  get '/privacy' => 'terms#privacy', as: :privacy

  get '/terms/provider' => 'terms#provider', as: :provider_terms

  get '/terms/teacher' => 'terms#teacher', as: :teacher_terms


  resources :channel_teachers, path: 'teachers', except: [:new, :show, :index]

  resources :channel_admins, path: 'admins', except: [:new, :show, :index] 

  resources :channel_plans, path: 'plans'

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
    end
  end

  resources :channels, path: 'providers', only: [:index, :teachers, :new, :create] do
    #resources :course_suggestions, only: [:new, :create], path: 'class_suggestions'
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
  post '/partners/said_hello', as: 'said_hello', controller: 'partners'

  get 'resources', to: 'resources#index', as: :resources
  get 'metrics', to: 'metrics#index', as: :metrics

  get 'topics', to: 'categories#index', as: :categories
  get 'categories', to: 'categories#index', as: :categories
  get '/classes/:year/:month/:day', to: 'courses#index', as: :classes_in_week

  #get '/regions/:region', to: 'courses#index', as: :region
  #get '/topics/:topic', to: 'courses#index', as: :category
  #get '/providers/:provider', to: 'courses#show', as: :channel_filter

  #TODO: find an easier way of doing these channel routes!
  get ':channel_url_name/admins', to: 'channels#admins', as: :channels_admins
  get 'providers/:channel_id/admins', to: 'channels#admins', as: :channel_channel_admins
  get ':channel_url_name/admins/new', to: 'channel_admins#new', as: :new_channel_admin
  get ':channel_url_name/admin/:id/edit', to: 'channel_admins#edit', as: :edit_channel_admin
  
  get 'providers/:channel_id/url_available/:url_name', to: 'channels#url_available', as: :channel_url_available
  get ':channel_url_name/teachers', to: 'channels#teachers', as: :channels_teachers
  get 'providers/:channel_id/teachers', to: 'channels#teachers', as: :channel_channel_teachers
  get ':channel_url_name/teachers/new', to: 'channel_teachers#new', as: :new_channel_teacher
  get ':channel_url_name/teacher/:id', to: 'channel_teachers#show', as: :channel_channel_teacher
  get ':channel_url_name/teacher/:id', to: 'channel_teachers#show', as: :channel_teacher
  get ':channel_url_name/settings', to: 'channels#edit', as: :channel_settings
  put ':channel_url_name/settings', to: 'channels#update', as: :channel_settings
  get ':channel_url_name/contact', to: 'channels#contact', as: :channel_contact
  post ':channel_url_name/contact', to: 'channels#contact', as: :channel_contact
  get ':channel_url_name/followers', to: 'channels#followers', as: :channel_followers
  get ':channel_url_name/:course_url_name', to: 'channels#series', as: :channel_course_series
  get '*channel_url_name/*course_url_name/:id', to: 'courses#show', as: :channel_course
  get ':channel_url_name', to: 'channels#show', as: :channel

  #TODO: will never be hit because of channel_course_series
  # constraints(MainDomain) do
  #   get ':country_code/:region_name', to: 'courses#index', constraints: {country_code: /[a-zA-Z]{2}/}
  # end
  match '*a', :to => 'application#not_found'
end
