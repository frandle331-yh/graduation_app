Rails.application.routes.draw do
  devise_for :users
  resource :profile, only: [:edit, :update, :destroy]
  resources :housework_templates, only: [:index, :new, :create, :edit, :update, :destroy] do
    post :use, on: :member
  end
  resources :housework_logs, only: [:index, :new, :create, :show, :edit, :update, :destroy] do
    post :quick_create, on: :collection
  end
  resource :dashboard, only: [:show]
  resource :household, only: [:new, :create, :show] do
    get  :join,  on: :collection
    post :join,  on: :collection
  end

  get "home/index"
  # ゲストログイン
  post "guest_sign_in", to: "guests#create"

  # アプリのトップページ
  root "home#index"

  # Railsのヘルスチェック（Rails7〜8のデフォルト）
  get "up" => "rails/health#show", as: :rails_health_check
end
