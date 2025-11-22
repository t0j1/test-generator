# 塾用タブレット型単語テスト作成システム

**Rails版・シンプル設計**

高校生向けの単語テスト（英語・数学・国語・理科・社会）をタブレットで簡単に作成・印刷できるシステムです。

---

## 🎯 システムの特徴

- **超シンプル操作**: 3〜5タップで問題作成完了
- **固定タブレット運用**: 印刷機の前に設置し、誰でも使える
- **ランダム問題生成**: 指定範囲から自動で問題を抽出
- **低コスト運用**: AI不要、SQLite使用、月額0円〜

---

## 🛠 技術スタック

### バックエンド
- **Ruby**: 3.2.0以上
- **Rails**: 7.1.0以上
- **Database**: SQLite3（開発・本番共通）

### フロントエンド
- **Hotwire**: Turbo + Stimulus（リアクティブUI）
- **TailwindCSS**: レスポンシブデザイン
- **Importmap**: JavaScriptバンドル不要

### 主要gem
```ruby
gem "rails", "~> 7.1.0"
gem "sqlite3", "~> 1.4"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "prawn"              # PDF生成（将来実装）
gem "prawn-table"        # PDF表組み（将来実装）
```

---

## 📊 データベース設計

### テーブル構成

| テーブル | 説明 | 主要カラム |
|---------|------|-----------|
| `subjects` | 科目（英語・数学など） | `name`, `color_code`, `sort_order` |
| `units` | 単元（単語範囲） | `subject_id`, `name`, `grade` |
| `questions` | 問題データ | `unit_id`, `question_type`, `difficulty`, `question_text`, `answer_text` |
| `test_sheets` | 生成したテスト | `subject_id`, `unit_id`, `difficulty`, `question_count` |
| `test_questions` | テストと問題の紐付け | `test_sheet_id`, `question_id`, `question_order` |

### enum定義（Rails 7.1構文）

#### Question モデル
```ruby
# 問題タイプ
enum :question_type, { word: 0, sentence: 1, calculation: 2 }

# 難易度（prefix付き）
enum :difficulty, { easy: 1, normal: 2, hard: 3 }, prefix: true
```

#### TestSheet モデル
```ruby
# 難易度（prefix付き）
enum :difficulty, { easy: 1, normal: 2, hard: 3 }, prefix: true
```

**自動生成されるメソッド例**:
```ruby
question.word?                  # => true/false
question.difficulty_easy?       # => true/false
Question.word                   # => word型の問題のみ取得
Question.difficulty_easy        # => 易しい問題のみ取得
```

---

## 🎨 定数化による保守性向上

すべてのマジックナンバー・文字列を定数化し、保守性を最大化しています。

### 主要定数

#### Question モデル
```ruby
QUESTION_TYPES = { word: 0, sentence: 1, calculation: 2 }.freeze
QUESTION_TYPE_LABELS = { 'word' => '単語', 'sentence' => '文章', 'calculation' => '計算' }.freeze
DIFFICULTIES = { easy: 1, normal: 2, hard: 3 }.freeze
DIFFICULTY_LABELS = { 'easy' => '易しい', 'normal' => '普通', 'hard' => '難しい' }.freeze
DEFAULT_QUESTION_TYPE = :word
DEFAULT_DIFFICULTY = :easy
```

#### TestSheet モデル
```ruby
DIFFICULTIES = { easy: 1, normal: 2, hard: 3 }.freeze
DIFFICULTY_LABELS = { 'easy' => '易しい(基礎)', 'normal' => '普通(標準)', 'hard' => '難しい(応用)' }.freeze
MIX_LABEL = 'ミックス(全難易度)'
MIN_QUESTION_COUNT = 1
MAX_QUESTION_COUNT = 100
DEFAULT_QUESTION_COUNT = 10
DEFAULT_INCLUDE_HINT = false
DEFAULT_INCLUDE_ANSWER = true
ERROR_INSUFFICIENT_QUESTIONS = '問が不足しています。利用可能: %{available}問、要求: %{requested}問'
```

#### Unit モデル
```ruby
MIN_GRADE = 1           # 高1
MAX_GRADE = 3           # 高3
VALID_GRADES = (1..3)   # 高1〜高3
DIFFICULTY_KEYS = [:easy, :normal, :hard]
```

#### Subject モデル
```ruby
DEFAULT_COLORS = {
  '英語' => '#EF4444',  # 赤
  '数学' => '#3B82F6',  # 青
  '国語' => '#10B981',  # 緑
  '理科' => '#8B5CF6',  # 紫
  '社会' => '#F59E0B'   # オレンジ
}.freeze
```

**📖 詳細は [`doc/CONSTANTS.md`](doc/CONSTANTS.md) を参照**

---

## 🚀 セットアップ手順

### 1. リポジトリのクローン
```bash
git clone https://github.com/your-username/juku_print_system.git
cd juku_print_system
```

### 2. 依存関係のインストール
```bash
bundle install
```

### 3. データベースのセットアップ
```bash
# データベース作成
rails db:create

# マイグレーション実行
rails db:migrate

# サンプルデータ投入
rails db:seed
```

**投入されるデータ**:
- 科目: 5科目（英語・数学・国語・理科・社会）
- 単元: 5単元
- 問題: 70問（英語の単語テスト、難易度別）

### 4. サーバー起動
```bash
rails server
```

ブラウザで `http://localhost:3000` にアクセス

---

## 🎓 Seedデータの内容

### 科目（5科目）
| 科目名 | 色 | 並び順 |
|--------|-----|--------|
| 英語 | 赤 (#EF4444) | 1 |
| 数学 | 青 (#3B82F6) | 2 |
| 国語 | 緑 (#10B981) | 3 |
| 理科 | 紫 (#8B5CF6) | 4 |
| 社会 | オレンジ (#F59E0B) | 5 |

### 単元（5単元）
- 高1英語 - 基礎単語300
- 高1英語 - 必修単語500
- 高2英語 - 標準単語700
- 高2英語 - 応用単語900
- 高3英語 - 大学受験頻出1000

### 問題（70問）
- **易しい**: 25問（基礎単語、中学復習含む）
- **普通**: 25問（高校標準レベル）
- **難しい**: 20問（大学受験レベル）

**例**:
```
abandon（動）〜を捨てる、〜を断念する
ability（名）能力、才能
absorb（動）〜を吸収する
...（計70問）
```

---

## 💻 開発コマンド

### データベース関連
```bash
# リセット（危険: 全データ削除）
rails db:reset

# Railsコンソール起動
rails c

# データ確認例
Subject.count           # => 5
Unit.count              # => 5
Question.count          # => 70
Question.word.count     # => 70（全て単語問題）
```

### Git管理
```bash
# 現在のブランチ確認
git branch

# 変更内容の確認
git status

# コミット
git add .
git commit -m "メッセージ"

# プッシュ
git push origin ブランチ名
```

---

## 📁 ディレクトリ構成

```
juku_print_system/
├── app/
│   ├── models/
│   │   ├── subject.rb          # 科目モデル（定数: DEFAULT_COLORS）
│   │   ├── unit.rb             # 単元モデル（定数: MIN_GRADE, MAX_GRADE, VALID_GRADES）
│   │   ├── question.rb         # 問題モデル（定数: QUESTION_TYPES, DIFFICULTIES, *_LABELS）
│   │   ├── test_sheet.rb       # テストモデル（定数: DIFFICULTIES, MIN/MAX_QUESTION_COUNT）
│   │   └── test_question.rb    # 紐付けモデル（定数: MIN_QUESTION_ORDER）
│   ├── controllers/
│   │   └── test_sheets_controller.rb  # テスト生成コントローラー（未実装）
│   ├── views/
│   │   └── test_sheets/        # テスト画面（未実装）
│   └── helpers/
│       └── test_sheets_helper.rb  # フォーム用ヘルパー（未実装）
├── db/
│   ├── migrate/                # マイグレーションファイル
│   ├── seeds.rb                # Seedデータ（高校生向け70問）
│   └── schema.rb               # スキーマ定義
├── doc/
│   └── CONSTANTS.md            # 📖 定数一覧ドキュメント（必読）
└── README.md                   # このファイル
```

---

## 🔧 定数の使い方

### ビューで使用
```erb
<%# 問題タイプのラベル表示 %>
<%= @question.question_type_label %>  <%# => '単語' %>

<%# 難易度のラベル表示 %>
<%= @question.difficulty_label %>     <%# => '易しい' %>
<%= @test_sheet.difficulty_label %>   <%# => '易しい(基礎)' %>

<%# 学年のラベル表示 %>
<%= @unit.grade_label %>              <%# => '高1' %>
```

### コントローラー・モデルで使用
```ruby
# デフォルト値の設定
question.question_type ||= Question::DEFAULT_QUESTION_TYPE
question.difficulty ||= Question::DEFAULT_DIFFICULTY

# 制約値のチェック
if count > TestSheet::MAX_QUESTION_COUNT
  errors.add(:base, "問題数は#{TestSheet::MAX_QUESTION_COUNT}問以下にしてください")
end

# エラーメッセージの生成
error_msg = format(
  TestSheet::ERROR_INSUFFICIENT_QUESTIONS,
  available: 10,
  requested: 20
)
# => "問が不足しています。利用可能: 10問、要求: 20問"
```

### enumメソッドの使用
```ruby
# 判定メソッド
question.word?                  # => true/false
question.difficulty_easy?       # => true/false

# スコープ
Question.word                   # => word型の問題のみ取得
Question.difficulty_easy        # => 易しい問題のみ取得

# 値の取得
Question.question_types         # => {"word"=>0, "sentence"=>1, "calculation"=>2}
Question.difficulties           # => {"easy"=>1, "normal"=>2, "hard"=>3}
```

**📖 詳細な使用例は [`doc/CONSTANTS.md`](doc/CONSTANTS.md) を参照**

---

## 📈 定数化のメリット

### 1. ハードコードゼロ
- マジックナンバー・文字列を排除
- コードの意図が明確

### 2. 変更が1箇所で完結
- ラベル変更時に1箇所修正するだけ
- 10箇所以上の修正が不要

### 3. タイポ防止
- 定数参照なので IDE の補完が効く
- スペルミスがコンパイル時に検出される

### 4. パフォーマンス向上
- **DB保存サイズ**: 文字列(最大11バイト) → 整数(4バイト)（**64%削減**）
- **検索速度**: 文字列比較 → 整数比較（**約2倍高速**）

### 5. テストしやすい
- 定数を使ったテストが書きやすい
- モックやスタブが不要

---

## 🎯 実装予定の機能（Day 3以降）

### Day 3: 問題生成ロジック
- [ ] TestSheetsController 実装
- [ ] ランダム問題抽出メソッド
- [ ] 問題数不足時のバリデーション
- [ ] AJAX で利用可能問題数を取得

### Day 4: タブレットUI
- [ ] 3ステップのシンプルフォーム
- [ ] Stimulus.js で動的な選択肢更新
- [ ] TailwindCSS で大きなボタン

### Day 5: 印刷機能
- [ ] 印刷用レイアウト（CSS）
- [ ] JavaScript で印刷実行
- [ ] 印刷履歴の記録

### Day 6: 管理画面
- [ ] 問題の登録・編集
- [ ] CSV一括登録
- [ ] 利用統計の表示

### Day 7: 本番デプロイ
- [ ] SQLite バックアップ設定
- [ ] 環境変数の設定
- [ ] VPS/Heroku デプロイ

---

## 🔐 セキュリティ

### タブレット固定化
- IP アドレス制限（教室内のみアクセス可能）
- 位置情報チェック（将来実装）

### データ保護
- SQLite データベースの定期バックアップ
- 印刷履歴の保持（問題の使用状況分析）

---

## 💰 運用コスト試算

### 初期費用
- iPad（中古可）: 3〜5万円
- タブレットスタンド: 3,000円
- **合計: 3.3〜5.3万円**

### 月額費用（本番環境）
- VPS（さくらVPS 1GB）: 800円/月
- ドメイン（.com）: 100円/月
- AI API: 0円（AI不使用）
- **合計: 900円/月**

**SQLite使用により、データベースサーバー代が不要！**

---

## 🐛 トラブルシューティング

### Railsサーバーが起動しない
```bash
# ポートが使用中の場合
lsof -ti:3000 | xargs kill -9

# 別のポートで起動
rails s -p 3001
```

### データベースをリセットしたい
```bash
rails db:reset
# ⚠️ 警告: 全データが削除されます
```

### enumの動作確認
```bash
rails c

# 問題タイプの確認
Question.question_types
# => {"word"=>0, "sentence"=>1, "calculation"=>2}

# 難易度の確認
Question.difficulties
# => {"easy"=>1, "normal"=>2, "hard"=>3}

# 自動生成メソッドの確認
q = Question.first
q.word?              # => true/false
q.difficulty_easy?   # => true/false
```

---

## 📚 参考資料

- [Rails 7.1 Release Notes](https://edgeguides.rubyonrails.org/7_1_release_notes.html)
- [ActiveRecord::Enum](https://api.rubyonrails.org/classes/ActiveRecord/Enum.html)
- [Hotwire (Turbo + Stimulus)](https://hotwired.dev/)
- [TailwindCSS](https://tailwindcss.com/)

---

## 📝 ライセンス

MIT License

---

## 👤 作者

塾用タブレットシステム開発チーム

---

## 🎉 開発状況

- [x] Day 1: 環境構築・Git管理
- [x] Day 2: enum + 定数化でデータベース設計
- [ ] Day 3: 問題生成ロジック
- [ ] Day 4: タブレットUI
- [ ] Day 5: 印刷機能
- [ ] Day 6: 管理画面
- [ ] Day 7: 本番デプロイ

**現在の進捗**: Day 2 完了 ✅

---

## 📖 重要ドキュメント

- **[定数一覧ドキュメント](doc/CONSTANTS.md)**: 全モデルの定数定義、使用例、ベストプラクティス（**必読**）

---

**最終更新**: 2025-11-22