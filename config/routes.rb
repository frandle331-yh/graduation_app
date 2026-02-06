Rails.application.routes.draw do
  get "housework_logs/index"
  get "housework_logs/new"
  get "housework_logs/create"
  get "profiles/edit"
  get "profiles/update"
  devise_for :users
  resource :profile, only: [:edit, :update, :destroy]
  resources :housework_logs, only: [:index, :new, :create, :show, :edit, :update]
  get "home/index"
  # アプリのトップページ
  root "home#index"

  # Railsのヘルスチェック（Rails7〜8のデフォルト）
  get "up" => "rails/health#show", as: :rails_health_check
end
