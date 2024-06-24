Rails.application.routes.draw do
  root to: "pages#home"
  get "up" => "rails/health#show", as: :rails_health_check
  get "about", to: "pages#about"
  post "results", to: "scrapes#results"
  get "display", to: "scrapes#display"
end
