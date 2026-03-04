Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  resource :profile, only: [ :edit, :update, :destroy ]
  resources :housework_templates, only: [ :index, :new, :create, :edit, :update, :destroy ] do
    post :use, on: :member
  end
  resources :housework_logs, only: [ :index, :new, :create, :show, :edit, :update, :destroy ] do
    post :quick_create,   on: :collection
    get  :search_titles,  on: :collection
    post :thanks,         on: :member
  end
  resource :dashboard, only: [ :show ]
  resource :household, only: [ :new, :create, :show ] do
    get  :join,  on: :collection
    post :join,  on: :collection
  end

  get "home/index"
  # 静的ページ（未ログインでもアクセス可）
  get "terms",          to: "pages#terms",          as: :terms
  get "privacy_policy", to: "pages#privacy_policy", as: :privacy_policy
  # ゲストログイン
  post "guest_sign_in", to: "guests#create"

  # アプリのトップページ
  root "home#index"

  # Railsのヘルスチェック（Rails7〜8のデフォルト）
  get "up" => "rails/health#show", as: :rails_health_check
end
