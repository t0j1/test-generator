# マイグレーションとテスト実行ガイド

## 🚨 重要な修正内容

以下の3つの問題を修正しました：

### 1. ✅ `discarded_at` カラムが存在しない問題
**原因**: Discardのマイグレーションが未実行  
**解決**: マイグレーション実行が必要

### 2. ✅ CSV ライブラリが見つからない問題
**原因**: Ruby 3.4+ では CSV が標準gemから分離  
**解決**: Gemfileに`gem "csv"`を追加済み

### 3. ✅ バリデーションメッセージが英語の問題
**原因**: 日本語ロケールファイルが未設定  
**解決**: `config/locales/ja.yml`を作成済み

---

## 📋 ローカル環境での対応手順

### ステップ1: 最新コードを取得

```bash
cd /workspaces/test-generator
git pull origin main
```

### ステップ2: 依存関係を更新

```bash
bundle install
```

**期待される出力**:
```
Fetching gem metadata from https://rubygems.org/
...
Installing csv X.X.X
...
Bundle complete!
```

### ステップ3: マイグレーションを実行

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
-- add_index(:questions, :discarded_at)
-- add_column(:test_sheets, :discarded_at, :datetime)
-- add_index(:test_sheets, :discarded_at)
== 20251123035818 AddDiscardedAtToModels: migrated (X.XXXXs) =================
```

### ステップ4: テストを実行

```bash
# 全テストを実行
bin/rails test

# 個別のテストを実行
bin/rails test test/models/question_test.rb
bin/rails test test/models/test_sheet_test.rb
```

---

## 🔍 修正内容の詳細

### 1. Gemfile の修正

```diff
 # Soft delete
 gem "discard", "~> 1.3"
 
+# CSV processing (required for Ruby 3.4+)
+gem "csv"
```

### 2. config/application.rb の修正

```diff
+    # Set default locale to Japanese
+    config.i18n.default_locale = :ja
+    config.i18n.available_locales = [:ja, :en]
```

### 3. config/locales/ja.yml の作成

日本語のバリデーションメッセージを定義：

```yaml
ja:
  activerecord:
    attributes:
      question:
        question_text: 問題文
        answer_text: 解答
      test_sheet:
        question_count: 問題数
        difficulty: 難易度

  errors:
    messages:
      blank: "を入力してください"
      taken: "はすでに存在します"
      greater_than_or_equal_to: "は%{count}以上の値にしてください"
      less_than_or_equal_to: "は%{count}以下の値にしてください"
```

### 4. Fixture の修正

enumの値を数値からシンボルに変更：

#### questions.yml:
```diff
 english_easy_1:
   unit: english_unit1
   question_type: word
   question_text: apple
   answer_text: りんご
-  difficulty: 1
+  difficulty: easy
```

#### test_sheets.yml:
```diff
 english_test_1:
   subject: english
   unit: english_unit1
   question_count: 3
-  difficulty: 1
+  difficulty: easy
```

---

## 🔧 トラブルシューティング

### Q: `discarded_at` カラムのエラーが出ます

**A:** マイグレーションを実行してください：

```bash
# スキーマにdiscarded_atが含まれているか確認
grep -A 5 "create_table \"questions\"" db/schema.rb | grep discarded_at

# 含まれていない場合、マイグレーションを実行
bin/rails db:migrate
bin/rails db:test:prepare
```

### Q: CSV エラーが出ます

**A:** 依存関係を更新してください：

```bash
bundle install

# Gemfile.lockにcsvが含まれているか確認
grep "csv" Gemfile.lock
```

### Q: バリデーションメッセージが英語のままです

**A:** 日本語ロケールファイルを確認してください：

```bash
# ja.ymlが存在するか確認
ls -la config/locales/ja.yml

# デフォルトロケールが設定されているか確認
grep "default_locale" config/application.rb
```

### Q: enum のエラーが出ます

**A:** fixtureのenum値をシンボルに変更してください：

```bash
# questions.yml
difficulty: 1  → difficulty: easy
difficulty: 2  → difficulty: normal  
difficulty: 3  → difficulty: hard

# test_sheets.yml
difficulty: 0  → difficulty: mix
difficulty: 1  → difficulty: easy
difficulty: 2  → difficulty: normal
```

---

## ✅ 期待される結果

すべての修正を適用した後：

```bash
bin/rails test
```

**期待される出力**:
```
Running 55 tests in parallel using 2 processes
Run options: --seed XXXXX

# Running:

.....................................................

Finished in X.XXXXs, XX.XXXX runs/s, XX.XXXX assertions/s.
55 runs, XX assertions, 0 failures, 0 errors, 0 skips
```

---

## 📊 修正ファイル一覧

| ファイル | 変更内容 |
|---------|---------|
| `Gemfile` | CSV gemを追加 |
| `config/application.rb` | 日本語ロケール設定を追加 |
| `config/locales/ja.yml` | 日本語バリデーションメッセージを作成 |
| `test/fixtures/questions.yml` | enum値を数値→シンボルに変更 |
| `test/fixtures/test_sheets.yml` | enum値を数値→シンボルに変更 |

---

## 🚀 最終確認コマンド

```bash
# 1. 最新コードを取得
git pull origin main

# 2. 依存関係を更新
bundle install

# 3. マイグレーションを実行
bin/rails db:migrate
bin/rails db:test:prepare

# 4. スキーマを確認
grep "discarded_at" db/schema.rb

# 5. 全テストを実行
bin/rails test

# 6. システムテストを実行
bin/rails test:system
```

---

## 📚 関連ドキュメント

- [FIXTURE_FIX_COMPLETE_GUIDE.md](FIXTURE_FIX_COMPLETE_GUIDE.md) - Fixture完全修正ガイド
- [CI_FIX_GUIDE.md](CI_FIX_GUIDE.md) - GitHub Actions CI修正ガイド

---

これで全ての問題が解消されるはずです！  
テストが正常に通ることを確認したら、開発を進めてください 🎉
