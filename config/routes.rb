require "sidekiq/web"
Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"
  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    root "static_pages#home"
    devise_for :users, controllers: {
      registrations: "users/registrations"
    }

    resources :rooms, only: %i(index show) do
      get :check_available, on: :member
      post :index, on: :collection
    end

    post "bookings/:id", to: "bookings#show", as: "booking"
    resources :bookings, except: :show

    resource :reviews, only: %i(create update)

    namespace :admin do
      get "dashboard", to: "dashboard#index"
      resources "bookings", only: %i(index show update)
      resources "users", only: %i(index show)
      post "lock/:id", to: "users#lock_user", as: "lock_user"
      post "unlock/:id", to: "users#unlock_user", as: "unlock_user"
    end
    delete "remove_profile_image/:id", to: "application#remove_profile_image", as: "remove_profile_image"
  end
end
