# 🚨 緊急修正ガイド - discarded_at カラム追加

## 問題の原因

マイグレーションファイルに **`questions` テーブルへの `discarded_at` カラム追加が漏れていました**。

これにより、以下のエラーが発生していました：
```
SQLite3::SQLException: no such column: questions.discarded_at
ActiveModel::UnknownAttributeError: unknown attribute 'discarded_at' for Question
```

## ✅ 修正内容

### 修正されたマイグレーションファイル

**db/migrate/20251123035818_add_discarded_at_to_models.rb**:

```ruby
class AddDiscardedAtToModels < ActiveRecord::Migration[8.1]
  def change
    # ✅ questions テーブルに追加（これが漏れていた）
    add_column :questions, :discarded_at, :datetime
    add_index :questions, :discarded_at
    
    add_column :test_sheets, :discarded_at, :datetime
    add_index :test_sheets, :discarded_at
  end
end
```

### 追加で修正された問題

**test/models/subject_test.rb**:
- 重複する科目名（"英語"）を修正
- "テスト科目A"、"テスト科目B" に変更

---

## 📋 必須の対応手順

### ステップ1: 最新コードを取得

```bash
cd /workspaces/test-generator
git pull origin main
```

**期待される出力**:
```
Updating 5064659..49934ff
Fast-forward
 db/migrate/20251123035818_add_discarded_at_to_models.rb | 4 +++-
 test/models/subject_test.rb                             | 6 +++---
 2 files changed, 6 insertions(+), 4 deletions(-)
```

### ステップ2: 既存のマイグレーションをロールバック

```bash
# マイグレーションの状態を確認
bin/rails db:migrate:status

# 問題のマイグレーションをロールバック
bin/rails db:rollback

# テストDBもロールバック
RAILS_ENV=test bin/rails db:rollback
```

### ステップ3: 修正されたマイグレーションを再実行

```bash
# 開発DBにマイグレーションを適用
bin/rails db:migrate

# テストDBにマイグレーションを適用
bin/rails db:test:prepare
```

**期待される出力**:
```
== 20251123035818 AddDiscardedAtToModels: migrating ==========================
-- add_column(:questions, :discarded_at, :datetime)
   -> 0.0XXXs
-- add_index(:questions, :discarded_at)
   -> 0.0XXXs
-- add_column(:test_sheets, :discarded_at, :datetime)
   -> 0.0XXXs
-- add_index(:test_sheets, :discarded_at)
   -> 0.0XXXs
== 20251123035818 AddDiscardedAtToModels: migrated (0.0XXXs) =================
```

### ステップ4: スキーマを確認

```bash
# questionsテーブルにdiscarded_atが追加されたことを確認
grep -A 3 "create_table \"questions\"" db/schema.rb | grep discarded_at
```

**期待される出力**:
```ruby
t.datetime "discarded_at"
t.index ["discarded_at"], name: "index_questions_on_discarded_at"
```

### ステップ5: テストを実行

```bash
# 全テストを実行
bin/rails test

# または個別に実行
bin/rails test test/models/question_test.rb
bin/rails test test/models/test_sheet_test.rb
bin/rails test test/models/unit_test.rb
```

---

## 🔧 トラブルシューティング

### Q: マイグレーションのロールバックが失敗します

**A:** データベースをリセットして再構築してください：

```bash
# 開発DBを削除して再構築
bin/rails db:drop db:create db:migrate

# テストDBを再構築
bin/rails db:test:prepare

# テストを実行
bin/rails test
```

### Q: 既にdiscarded_atカラムが存在するエラーが出ます

**A:** スキーマを確認して、カラムが存在する場合はロールバックしてください：

```bash
# スキーマを確認
cat db/schema.rb | grep -A 10 "create_table \"questions\""

# カラムが存在する場合、マイグレーション履歴を確認
bin/rails db:migrate:status

# 最後のマイグレーションをロールバック
bin/rails db:rollback
RAILS_ENV=test bin/rails db:rollback

# 再度マイグレーション
bin/rails db:migrate
bin/rails db:test:prepare
```

### Q: まだdiscarded_atエラーが出ます

**A:** テストDBのスキーマを確認してください：

```bash
# テストDBのスキーマを確認
sqlite3 db/test.sqlite3 ".schema questions" | grep discarded_at

# 出力が空の場合、テストDBを完全再構築
rm -f db/test.sqlite3
bin/rails db:test:prepare
```

---

## 📊 修正前後の比較

### Before (誤り):
```ruby
class AddDiscardedAtToModels < ActiveRecord::Migration[8.1]
  def change
    # ❌ questions テーブルへの追加が漏れている
    add_column :test_sheets, :discarded_at, :datetime
    add_index :test_sheets, :discarded_at
    
    add_column :test_questions, :discarded_at, :datetime
    add_index :test_questions, :discarded_at
  end
end
```

### After (正しい):
```ruby
class AddDiscardedAtToModels < ActiveRecord::Migration[8.1]
  def change
    # ✅ questions テーブルへの追加を追加
    add_column :questions, :discarded_at, :datetime
    add_index :questions, :discarded_at
    
    add_column :test_sheets, :discarded_at, :datetime
    add_index :test_sheets, :discarded_at
  end
end
```

---

## ✅ 期待される結果

すべての修正を適用した後、以下のテストが通るはずです：

### 通るべきテスト:
- ✅ `QuestionTest#test_discarded_questions_are_excluded_by_default`
- ✅ `QuestionTest#test_kept_questions_are_included_by_default`
- ✅ `QuestionTest#test_valid_question`
- ✅ `UnitTest#test_question_count_returns_total_questions`
- ✅ `UnitTest#test_question_count_with_difficulty_filters_questions`
- ✅ `TestSheetTest#test_generate_questions!_creates_correct_number_of_questions`

---

## 🚀 最終確認コマンド

```bash
# 1. 最新コードを取得
git pull origin main

# 2. マイグレーションをロールバック
bin/rails db:rollback
RAILS_ENV=test bin/rails db:rollback

# 3. マイグレーションを再実行
bin/rails db:migrate
bin/rails db:test:prepare

# 4. スキーマを確認
grep "discarded_at" db/schema.rb

# 期待される出力: questions, test_sheets の両方に discarded_at が存在
# t.datetime "discarded_at"
# t.index ["discarded_at"], name: "index_questions_on_discarded_at"
# t.index ["discarded_at"], name: "index_test_sheets_on_discarded_at"

# 5. 全テストを実行
bin/rails test
```

---

## 📦 Git コミット情報

**Commit**: `49934ff`  
**Message**: "Fix: questionsテーブルにdiscarded_atカラムを追加"

**修正ファイル** (2ファイル):
1. `db/migrate/20251123035818_add_discarded_at_to_models.rb` - questions テーブルの追加
2. `test/models/subject_test.rb` - 重複name修正

---

## 📚 関連ドキュメント

- [MIGRATION_AND_TEST_GUIDE.md](MIGRATION_AND_TEST_GUIDE.md) - マイグレーションとテスト実行ガイド
- [FIXTURE_FIX_COMPLETE_GUIDE.md](FIXTURE_FIX_COMPLETE_GUIDE.md) - Fixture完全修正ガイド

---

これで `discarded_at` 関連のエラーは **完全に解消** されるはずです！  
マイグレーションのロールバック→再実行を忘れずに行ってください 🎉
