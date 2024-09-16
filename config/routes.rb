Rails.application.routes.draw do
  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"
  root to: "pages#home"
  get "up" => "rails/health#show", as: :rails_health_check
  get "about", to: "pages#about"
  resources :pulls, only: [:create, :destroy] do
    resources :scrapes, only: [:create, :index]
  end
  resources :scrapes, only: [:index]
end
