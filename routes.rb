Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  
  namespace :admin do
    root to: "dashboard#index"
    
    resources :dashboard, only: [:index]
    
    resources :products do
      member do
        patch :toggle_active
        patch :toggle_featured
      end
      resources :variants, controller: "product_variants"
    end
    
    resources :categories do
      member do
        patch :toggle_active
      end
      collection do
        post :reorder
      end
    end
    
    resources :orders do
      member do
        patch :confirm
        patch :process_order
        patch :ship
        patch :deliver
        patch :cancel
      end
      resources :shipments, only: [:create, :update]
    end
    
    resources :users do
      member do
        patch :toggle_active
      end
    end
    
    resources :coupons do
      member do
        patch :toggle_active
      end
    end
    
    resources :reviews do
      member do
        patch :approve
        patch :reject
      end
    end
    
    namespace :reports do
      get :sales
      get :inventory
      get :customers
      get :export_sales
      get :export_inventory
    end
  end
  
  namespace :api do
    namespace :v1 do
      resources :products, only: [:index, :show]
      resources :categories, only: [:index, :show]
      
      resource :cart, only: [:show] do
        post :add_item
        patch :update_item
        delete :remove_item
        delete :clear
      end
      
      resources :orders, only: [:index, :show, :create]
      
      post "webhooks/stripe", to: "webhooks#stripe"
      post "webhooks/pagseguro", to: "webhooks#pagseguro"
      post "webhooks/mercadopago", to: "webhooks#mercadopago"
    end
  end
  
  root to: "catalog#index"
  
  get "catalog", to: "catalog#index", as: :catalog
  get "catalog/search", to: "catalog#search", as: :catalog_search
  get "catalog/category/:slug", to: "catalog#category", as: :catalog_category
  
  resources :products, only: [:show] do
    resources :reviews, only: [:create]
  end
  
  resource :cart, only: [:show] do
    post :add_item
    patch :update_item
    delete :remove_item
    delete :clear
  end
  
  resource :checkout, only: [:show, :create] do
    get :addresses
    post :set_addresses
    get :shipping
    post :set_shipping
    get :payment
    post :process_payment
    get :confirmation
  end
  
  resources :orders, only: [:index, :show]
  
  resource :wishlist, only: [:show] do
    post :add_item
    delete :remove_item
    post :move_to_cart
  end
  
  scope :account do
    get "/", to: "accounts#show", as: :account
    get "/edit", to: "accounts#edit", as: :edit_account
    patch "/", to: "accounts#update"
    
    resources :addresses, except: [:show] do
      member do
        patch :set_default
      end
    end
    
    get "/orders", to: "accounts#orders", as: :account_orders
    get "/wishlist", to: "accounts#wishlist", as: :account_wishlist
  end
  
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  
  require "sidekiq/web"
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end
  
  get "up" => "rails/health#show", as: :rails_health_check
end
