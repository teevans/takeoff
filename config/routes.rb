Rails.application.routes.draw do
  # Redirect to localhost from 127.0.0.1 to use same IP address with Vite server
  constraints(host: "127.0.0.1") do
    get "(*path)", to: redirect { |params, req| "#{req.protocol}localhost:#{req.port}/#{params[:path]}" }
  end

  root "dashboard#index"
  get "dashboard", to: "dashboard#index"

  resource :session, controller: "sessions" do
    collection do
      get :verify
    end
  end

  resource :signups, only: %i[new create]

  # Companies and related resources
  resources :companies do
    resources :company_invitations, only: [ :new, :create, :index, :destroy ]
  end

  resources :company_invitations, only: [ :show ]
  resources :company_redemptions, only: [ :create ]
  resource :company_switch, only: [ :update ]

  # Projects (scoped to Current.company in controller)
  resources :projects

  # Notifications
  resources :notification_settings, only: [:index] do
    member do
      patch :update_subscription
    end
    collection do
      patch :update_settings
    end
  end
  
  resources :notification_center, only: [:index] do
    member do
      patch :mark_read
    end
    collection do
      patch :mark_all_read
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
