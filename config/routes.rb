require 'routing_constraints'
Chalkle::Application.routes.draw do

  #ActiveAdmin.routes(self)

  match '(*any)' => redirect { |p, req| req.url.sub!('my.', '') } , :constraints => { :host => /^my\./ }
  match '(*any)' => redirect { |p, req| req.url.sub!('www.', '') } , :constraints => { :host => /^www\./ }

  devise_for :chalklers, controllers: { omniauth_callbacks: 'people/omniauth_callbacks', registrations: 'people/registrations' }
  
  constraints(Subdomain) do
    match '/' => 'channels#show'
  end

  root to: 'courses#index'
  
  get '/about' => 'application#about', as: :about

  get '/terms' => 'terms#chalkler', as: :terms

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

    resource :course_notices, only: [:create, :update, :destroy]
    
    resources :bookings do
      get :payment_callback
      collection { get 'csv' }
      member do
        get 'cancel'
        put 'cancel', to: 'bookings#confirm_cancel', as: :cancel
      end
    end

    collection do
      get 'calculate_cost'
      get 'mine'
    end
    
  end

  get '/c/:id' => 'courses#tiny_url', as: :course_tiny
  post '/bookings/lpn', as: :lpn
  namespace :me do
    root to: 'dashboard#index'
    get '/bookings' => 'dashboard#bookings', as: :bookings
    get '/preferences' => 'preferences#show', as: :preferences
    put '/preferences' => 'preferences#save', as: :preferences
    get '/enter_email' => 'preferences#enter_email', as: :enter_email
    put '/enter_email' => 'preferences#enter_email', as: :enter_email
  end

  namespace :sudo do
    root to: 'silvias#index'
    resources :partner_inquiries, path: 'hellos', only: [:index,:show,:edit]
    resources :payments
    resources :metrics, only: :index
    resources :regions
    resources :chalklers do
      collection do
        get 'becoming/:id' => 'chalklers#becoming', as: :becoming
        get 'become'
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
    collection do
    #   get '/preferences/meetup_email_settings' => 'preferences#meetup_email_settings', as: :meetup_email_settings
       post 'exists'
    #   delete '/preferences/destroy_chalkler/:id' => 'preferences#destroy', as: :delete
    #   get  '/data_collection/:action', as: 'data_collection', controller: :data_collection_form
    #   post '/data_collection/:action', as: 'data_collection_update', controller: :data_collection_form
    end
  end

  resources :channels, path: 'providers', only: [:index, :teachers, :new, :create] do
    #resources :course_suggestions, only: [:new, :create], path: 'class_suggestions'
    resources :subscriptions, only: [:create, :destroy], path: 'follow'
  end

  get '/styleguide' => 'application#styleguide', as: 'styleguide'
  #match '/image' => 'image#generate'


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
