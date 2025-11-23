# Fixture エラー完全修正ガイド

## 🎯 修正完了サマリー

すべてのfixture関連エラーを修正しました：

### ✅ 修正1: `hint_text` カラム名エラー (Commit: 9a94f2a, 23044fa)

**問題**: `ActiveRecord::Fixture::FixtureError: table "questions" has no columns named "hint_text"`

**原因**: コード内で`hint_text`を参照していたが、DBスキーマは`hint`カラムのみ

**修正箇所**:
- `test/fixtures/questions.yml` - `hint_text:` → `hint:`
- `app/models/question.rb` - CSV import logic
- `app/views/test_sheets/show.html.erb` - view template
- `test/system/admin/questions_test.rb` - system test

### ✅ 修正2: Foreign Key Violations (Commit: 184192f)

**問題**: `RuntimeError: Foreign key violations found: test_sheets, test_questions`

**原因**: `test_sheets.yml`と`test_questions.yml`が存在しないfixture IDを参照

**修正内容**:

#### Before (誤り):
```yaml
# test_sheets.yml
one:
  subject: one      # ← 存在しない
  unit: one         # ← 存在しない

# test_questions.yml
one:
  question: one     # ← 存在しない
```

#### After (正しい):
```yaml
# test_sheets.yml
english_test_1:
  subject: english        # ✓ subjects.yml に存在
  unit: english_unit1     # ✓ units.yml に存在

# test_questions.yml
english_test_q1:
  test_sheet: english_test_1    # ✓ test_sheets.yml に存在
  question: english_easy_1      # ✓ questions.yml に存在
```

## 📋 ローカル環境での対応手順

### ステップ1: 最新コードを取得

```bash
cd /workspaces/test-generator
git fetch origin
git pull origin main
```

### ステップ2: 依存関係を更新（必要な場合）

```bash
bundle install
```

### ステップ3: テストデータベースを完全再構築

```bash
# テストDBを削除（古いキャッシュをクリア）
rm -f db/test.sqlite3

# テストDBを再作成
bin/rails db:test:prepare
```

### ステップ4: テストを実行

```bash
# 個別のモデルテストを実行
bin/rails test test/models/question_test.rb
bin/rails test test/models/test_sheet_test.rb
bin/rails test test/models/unit_test.rb
bin/rails test test/models/subject_test.rb

# 全モデルテストを実行
bin/rails test test/models/

# 全テストを実行
bin/rails test

# システムテストを実行
bin/rails test:system
```

## 🔍 修正内容の詳細

### 1. questions.yml の修正

全10箇所の`hint_text`を`hint`に変更：

```yaml
english_easy_1:
  unit: english_unit1
  question_type: word
  question_text: apple
  answer_text: りんご
  hint: 赤い果物        # ← hint_text から hint に変更
  difficulty: 1
```

### 2. test_sheets.yml の修正

実際のfixture名に対応した4つのテストシートを作成：

```yaml
english_test_1:
  subject: english           # subjects.yml の english を参照
  unit: english_unit1        # units.yml の english_unit1 を参照
  question_count: 3
  difficulty: 1
  include_hint: true
  include_answer: true

math_test_1:
  subject: math              # subjects.yml の math を参照
  unit: math_unit1           # units.yml の math_unit1 を参照
  question_count: 2
  difficulty: 2
  include_hint: false
  include_answer: true

english_test_2:
  subject: english
  unit: english_unit2        # units.yml の english_unit2 を参照
  question_count: 1
  difficulty: 1

mix_test:
  subject: math
  unit: math_unit1
  question_count: 2
  difficulty: 0              # 0 = mix (全難易度)
  include_hint: true
  include_answer: true
```

### 3. test_questions.yml の修正

実際のfixture名に対応した6つのテスト問題を作成：

```yaml
english_test_q1:
  test_sheet: english_test_1     # test_sheets.yml の english_test_1 を参照
  question: english_easy_1       # questions.yml の english_easy_1 を参照
  question_order: 1

english_test_q2:
  test_sheet: english_test_1
  question: english_easy_2
  question_order: 2

english_test_q3:
  test_sheet: english_test_1
  question: english_easy_3
  question_order: 3

math_test_q1:
  test_sheet: math_test_1
  question: math_easy_1
  question_order: 1

math_test_q2:
  test_sheet: math_test_1
  question: math_normal_1
  question_order: 2

english_test2_q1:
  test_sheet: english_test_2
  question: english_unit2_easy_1
  question_order: 1
```

## 🎯 Fixture の関連図

```
subjects.yml
├── english (id: 1)
└── math (id: 2)
    ↓
units.yml
├── english_unit1 (subject: english)
├── english_unit2 (subject: english)
└── math_unit1 (subject: math)
    ↓
questions.yml
├── english_easy_1 (unit: english_unit1)
├── english_easy_2 (unit: english_unit1)
├── english_easy_3 (unit: english_unit1)
├── english_unit2_easy_1 (unit: english_unit2)
├── math_easy_1 (unit: math_unit1)
└── math_normal_1 (unit: math_unit1)
    ↓
test_sheets.yml
├── english_test_1 (subject: english, unit: english_unit1)
├── math_test_1 (subject: math, unit: math_unit1)
├── english_test_2 (subject: english, unit: english_unit2)
└── mix_test (subject: math, unit: math_unit1)
    ↓
test_questions.yml
├── english_test_q1 (test_sheet: english_test_1, question: english_easy_1)
├── english_test_q2 (test_sheet: english_test_1, question: english_easy_2)
├── english_test_q3 (test_sheet: english_test_1, question: english_easy_3)
├── math_test_q1 (test_sheet: math_test_1, question: math_easy_1)
├── math_test_q2 (test_sheet: math_test_1, question: math_normal_1)
└── english_test2_q1 (test_sheet: english_test_2, question: english_unit2_easy_1)
```

## 🔧 トラブルシューティング

### Q: まだ `hint_text` エラーが出ます

**A:** 以下を確認してください：

```bash
# 1. 最新コードを取得済みか確認
git log --oneline -3
# 期待される出力:
# 184192f Fix: fixture外部キー制約違反を修正
# 23044fa Fix: ビューファイルのhint_textをhintに修正
# 9a94f2a Fix: fixtureのカラム名をhint_textからhintに修正

# 2. ローカルに hint_text が残っていないか確認
grep -r "hint_text" --include="*.rb" --include="*.yml" --include="*.erb" . | grep -v ".git"
# 期待される出力: (何も表示されない)

# 3. テストDBを完全削除して再構築
rm -f db/test.sqlite3
bin/rails db:test:prepare
```

### Q: Foreign key violations エラーが出ます

**A:** fixtureの参照関係を確認してください：

```bash
# subjects.yml に english と math が存在するか
grep -E "^(english|math):" test/fixtures/subjects.yml

# units.yml に english_unit1 などが存在するか
grep -E "^(english_unit1|math_unit1):" test/fixtures/units.yml

# questions.yml に english_easy_1 などが存在するか
grep -E "^(english_easy_1|math_easy_1):" test/fixtures/questions.yml
```

### Q: テストが通らない別のエラーが出ます

**A:** エラーメッセージを確認して、以下を試してください：

```bash
# キャッシュをクリア
bin/rails tmp:clear

# Gemfileが更新されている場合
bundle install

# マイグレーションが追加されている場合
bin/rails db:migrate
bin/rails db:test:prepare
```

## 📊 修正コミット一覧

| Commit | メッセージ | 修正内容 |
|--------|-----------|---------|
| `9a94f2a` | Fix: fixtureのカラム名をhint_textからhintに修正 | questions.yml, question.rb, questions_test.rb |
| `23044fa` | Fix: ビューファイルのhint_textをhintに修正 | test_sheets/show.html.erb |
| `d4511de` | docs: hint_textエラー修正の完全ガイドを追加 | HINT_TEXT_FIX_GUIDE.md |
| `184192f` | Fix: fixture外部キー制約違反を修正 | test_sheets.yml, test_questions.yml |

## 🚀 最終確認コマンド

```bash
# 1. コードを最新化
git pull origin main

# 2. 依存関係を更新
bundle install

# 3. テストDBを完全再構築
rm -f db/test.sqlite3
bin/rails db:test:prepare

# 4. 全テストを実行
bin/rails test

# 5. 結果を確認
# 期待される結果: すべてのテストがパス（Errors: 0）
```

## ✅ 期待される結果

すべての修正を適用した後、以下のような結果が期待されます：

```
Finished in X.XXXXXs, XX.XXXX runs/s, XX.XXXX assertions/s.
XX runs, XX assertions, 0 failures, 0 errors, 0 skips
```

---

これで全てのfixture関連エラーは解消されているはずです！  
テストが正常に通ることを確認したら、開発を進めてください 🎉
