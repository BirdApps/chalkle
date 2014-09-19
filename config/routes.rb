require 'routing_constraints'
Chalkle::Application.routes.draw do

  ActiveAdmin.routes(self)

  match '(*any)' => redirect { |p, req| req.url.sub!('my.', '') } , :constraints => { :host => /^my\./ }
  match '(*any)' => redirect { |p, req| req.url.sub!('www.', '') } , :constraints => { :host => /^www\./ }

  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :chalklers, controllers: { omniauth_callbacks: 'people/omniauth_callbacks', registrations: 'people/registrations' }
  
  constraints(Subdomain) do
    match '/' => 'channels#show'
  end


  root to: 'courses#index'
  
  resources :channel_teachers, path: 'teachers', except: [:new] 

  resources :channel_plans, path: 'plans'

  resources :courses, path: 'classes' do
    resources :notices
    resources :bookings do
      member do
        put 'cancel'
      end
    end
    member do
      put 'change_status', to: 'courses#change_status', as: :change_status
    end
    collection do
      get 'calculate_cost'
    end
  end

  namespace :me do
    root to: 'dashboard#index'
    get '/bookings' => 'dashboard#bookings', as: :bookings
    get '/preferences' => 'preferences#show', as: :preferences
    put '/preferences' => 'preferences#save', as: :preferences
    get '/enter_email' => 'preferences#enter_email', as: :enter_email
    put '/enter_email' => 'preferences#enter_email', as: :enter_email
  end

  resources :chalklers, path: 'people' do
    collection do
      get '/preferences/meetup_email_settings' => 'preferences#meetup_email_settings', as: :meetup_email_settings

      delete '/preferences/destroy_chalkler/:id' => 'preferences#destroy', as: :delete
      get  '/data_collection/:action', as: 'data_collection', controller: :data_collection_form
      post '/data_collection/:action', as: 'data_collection_update', controller: :data_collection_form
    end
  end

  resources :channels, path: 'providers', only: [:index, :teachers] do
    resources :course_suggestions, only: [:new, :create], path: 'class_suggestions'
    resources :subscriptions, only: [:create, :destroy], path: 'follow'
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

  get 'resources', to: 'resources#index', as: :resources
  get 'metrics', to: 'metrics#index', as: :metrics

  get 'categories', to: 'categories#index', as: :categories

  get '/classes/:year/:month/:day', to: 'courses#index', as: :classes_in_week

  get '/regions/:region', to: 'courses#index', as: :region
  get '/categories/:topic', to: 'courses#index', as: :category
  get '/providers/:provider', to: 'courses#show', as: :channel_filter
  get '/search/:search', to: 'courses#index', as: :search_courses
  get '/search', to: 'courses#index', as: :search_courses

  #TODO: find an easier way of doing these channel routes!
  get ':channel_url_name/teachers', to: 'channels#teachers', as: :channels_teachers
  get 'providers/:channel_id/teachers', to: 'channels#teachers', as: :channel_channel_teachers
  get 'providers/:channel_id/url_available/:url_name', to: 'channels#url_available', as: :channel_url_available
  get ':channel_url_name/teachers/new', to: 'channels#teacher_new', as: :new_channel_teacher
  get ':channel_url_name/teacher/:id', to: 'channel_teachers#show', as: :channel_channel_teacher
  get ':channel_url_name/settings', to: 'channels#edit', as: :channel_settings
  put ':channel_url_name/settings', to: 'channels#update', as: :channel_settings
  get ':channel_url_name/contact', to: 'channels#contact', as: :channel_contact
  get ':channel_url_name/followers', to: 'channels#followers', as: :channel_followers
    get ':channel_url_name/:course_url_name', to: 'channels#series', as: :channel_course_series
  get '*channel_url_name/*course_url_name/:id', to: 'courses#show', as: :channel_course
  get ':channel_url_name', to: 'channels#show', as: :channel

  #TODO: will never be hit because of channel_course_series
  constraints(MainDomain) do
    get ':country_code/:region_name', to: 'courses#index', constraints: {country_code: /[a-zA-Z]{2}/}
  end
end
