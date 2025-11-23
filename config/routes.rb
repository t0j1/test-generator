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
end
