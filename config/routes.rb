Rails.application.routes.draw do
  root to: "pages#home"
  get "up" => "rails/health#show", as: :rails_health_check
  get "about", to: "pages#about"
  resources :pulls, only: [:create, :destroy] do
    resources :scrapes, only: [:create, :index]
  end
  resources :scrapes, only: [:index]
  # Sidekiq test routes
  # route where any visitor require the helloWorldJob to be triggered
  get "other/index"
  post "other/trigger_job"
  # post "welcome/trigger_job"
  # where visitor are redirected once job has been called
  get "other/job_done"
end
