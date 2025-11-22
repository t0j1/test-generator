# 塾用タブレット型単語テスト作成システム

## 概要
固定タブレットから単語テストを簡単に作成・印刷できるシステム

## 技術スタック
- Ruby 3.2.0
- Rails 7.1.0
- SQLite3
- TailwindCSS
- Hotwire (Turbo + Stimulus)

## セットアップ

```bash
# 依存関係インストール
bundle install

# データベース作成
rails db:create

# マイグレーション実行
rails db:migrate

# 初期データ投入
rails db:seed

# サーバー起動
rails server
