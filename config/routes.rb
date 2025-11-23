Rails.application.routes.draw do
  get "test_pages/index"
  # ヘルスチェック
  get "up" => "rails/health#show", as: :rails_health_check

  # ルートパス（テスト作成画面）
  root "test_sheets#new"

  # テストシート関連
  resources :test_sheets, only: %i[new create show index] do
    member do
      get :preview              # 印刷プレビュー
      post :mark_printed        # 印刷済みマーク
    end

    collection do
      get :history              # 印刷履歴
      get :available_questions  # AJAX: 利用可能な問題数取得
      get :units_by_subject     # AJAX: 科目別の単元リスト取得
    end
  end

  # 管理画面
  namespace :admin do
    root "dashboard#index"
    
    # ダッシュボード
    resource :dashboard, only: [:show], controller: "dashboard"
    
    # 問題管理
    resources :questions do
      collection do
        get :import_form        # CSVインポートフォーム
        post :import            # CSVインポート実行
        get :export             # CSVエクスポート
      end
    end
    
    # 科目管理
    resources :subjects, only: [:index, :show]
    
    # 単元管理
    resources :units, only: [:index, :show]
  end
end
