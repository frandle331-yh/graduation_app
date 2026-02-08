Rails.application.routes.draw do
  get "dashboards/show"
  get "housework_logs/index"
  get "housework_logs/new"
  get "housework_logs/create"
  get "profiles/edit"
  get "profiles/update"
  devise_for :users
  resource :profile, only: [:edit, :update, :destroy]
  resources :housework_logs, only: [:index, :new, :create, :show, :edit, :update, :destroy]
  resource :dashboard, only: [:show]
  resource :household, only: [:new, :create, :show] do
    get  :join,  on: :collection
    post :join,  on: :collection
  end

  get "home/index"
  # アプリのトップページ
  root "home#index"

  # Railsのヘルスチェック（Rails7〜8のデフォルト）
  get "up" => "rails/health#show", as: :rails_health_check
end
