# hint_text エラー完全修正ガイド

## 🔍 問題の原因

```
ActiveRecord::Fixture::FixtureError: table "questions" has no columns named "hint_text"
```

このエラーは、コード内で `hint_text` を参照していたのに対し、実際のDBスキーマでは `hint` カラムしか存在しなかったためです。

## ✅ 修正完了項目

以下のファイルを修正しました：

### 1. `test/fixtures/questions.yml`
```diff
- hint_text: 赤い果物
+ hint: 赤い果物
```

### 2. `app/models/question.rb`
```diff
- hint_text: row["ヒント"] || row["hint_text"]
+ hint: row["ヒント"] || row["hint"]
```

### 3. `test/system/admin/questions_test.rb`
```diff
- fill_in "question[hint_text]", with: "挨拶"
+ fill_in "question[hint]", with: "挨拶"
```

### 4. `app/views/test_sheets/show.html.erb`
```diff
- <% if @test_sheet.include_hint? && question.hint_text.present? %>
-   💡 ヒント: <%= question.hint_text %>
+ <% if @test_sheet.include_hint? && question.hint.present? %>
+   💡 ヒント: <%= question.hint %>
```

## 📋 ローカル環境での対応手順

コードの修正は完了しましたが、**テストデータベースのキャッシュが古い可能性**があります。

### ステップ1: 最新コードを取得

```bash
cd /workspaces/test-generator
git pull origin main
```

### ステップ2: テストデータベースを再構築

```bash
# テストDBのスキーマを最新の状態に更新
bin/rails db:test:prepare
```

### ステップ3: テストを実行

```bash
# 特定のモデルテストを実行
bin/rails test test/models/question_test.rb

# 全テストを実行
bin/rails test

# システムテストを実行
bin/rails test:system
```

## 🔧 それでもエラーが出る場合

### オプション1: テストDBを完全削除して再構築

```bash
# テストDBを削除
rm -f db/test.sqlite3

# テストDBを再作成
bin/rails db:test:prepare

# テスト実行
bin/rails test
```

### オプション2: 開発DBとテストDBを両方再構築

```bash
# 開発DBを削除
rm -f db/development.sqlite3 db/test.sqlite3

# マイグレーションを実行
bin/rails db:migrate
bin/rails db:test:prepare

# テスト実行
bin/rails test
```

## 🎯 確認方法

### 1. スキーマを確認

```bash
cat db/schema.rb | grep -A 10 'create_table "questions"'
```

**正しい出力:**
```ruby
create_table "questions", force: :cascade do |t|
  t.text "answer_text"
  t.datetime "created_at", null: false
  t.integer "difficulty"
  t.text "hint"            # ← これが正しい
  t.text "question_text"
  # ...
end
```

### 2. fixtureを確認

```bash
head -20 test/fixtures/questions.yml
```

**正しい出力:**
```yaml
english_easy_1:
  unit: english_unit1
  question_type: word
  question_text: apple
  answer_text: りんご
  hint: 赤い果物        # ← hint_text ではなく hint
  difficulty: 1
```

### 3. コード内に hint_text が残っていないか確認

```bash
grep -r "hint_text" --include="*.rb" --include="*.yml" --include="*.erb" . | grep -v ".git"
```

**正しい出力:** (何も出力されないはず)

## 📊 修正コミット情報

- **Commit 1**: `9a94f2a` - "Fix: fixtureのカラム名をhint_textからhintに修正"
- **Commit 2**: `23044fa` - "Fix: ビューファイルのhint_textをhintに修正"

## 🚀 最終確認コマンド

```bash
# 1. コードを最新化
git pull origin main

# 2. 依存関係を更新
bundle install

# 3. テストDBを準備
bin/rails db:test:prepare

# 4. モデルテストを実行
bin/rails test test/models/question_test.rb

# 5. 全テストを実行
bin/rails test

# 6. システムテストを実行（時間がかかります）
bin/rails test:system
```

## ❓ よくある質問

### Q: まだ `hint_text` エラーが出ます

**A:** 以下を確認してください：

1. `git pull origin main` で最新コードを取得済みか
2. `bin/rails db:test:prepare` を実行済みか
3. `tmp/cache/` や `.wrangler/` などのキャッシュディレクトリがないか

### Q: テストが通らない別のエラーが出ます

**A:** エラーメッセージを確認して、以下を試してください：

```bash
# Gemfileが更新されている場合
bundle install

# マイグレーションが追加されている場合
bin/rails db:migrate
bin/rails db:test:prepare

# キャッシュをクリア
bin/rails tmp:clear
```

### Q: システムテストが失敗します

**A:** Capybara + Seleniumの環境が必要です：

```bash
# Chromeが必要
which google-chrome || which chromium

# ChromeDriverが必要（自動インストールされるはず）
bundle exec rails test:system
```

## 📚 関連ドキュメント

- [CI_FIX_GUIDE.md](CI_FIX_GUIDE.md) - GitHub Actions CI エラーの修正ガイド
- [Rails Testing Guide](https://guides.rubyonrails.org/testing.html)
- [Fixtures Documentation](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html)

---

これで `hint_text` 関連のエラーは完全に解消されるはずです！
テストが正常に通ることを確認したら、開発を進めてください 🎉
