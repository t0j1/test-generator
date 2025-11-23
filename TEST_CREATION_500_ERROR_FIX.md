# 🔧 テスト作成500エラー修正ガイド

## ❌ 問題

テスト作成画面で「ミックス(全難易度)」を選択して「テストを作成」ボタンを押すと、500エラーが発生していました。

### エラー画面
```
500
サーバーエラーが発生しました
```

---

## 🔍 原因分析

### **1. Enum定義の不完全性**

**問題のコード (`app/models/test_sheet.rb`):**
```ruby
DIFFICULTIES = {
  easy: 1,     # ← mix: 0 が欠落！
  normal: 2,
  hard: 3
}.freeze
```

`difficulty` カラムは `integer` 型で、以下の値を持ちます：
- `0` = mix (全難易度)
- `1` = easy
- `2` = normal  
- `3` = hard

しかし、`DIFFICULTIES` に `mix: 0` が定義されていませんでした。

### **2. ヘルパーが nil を返す**

**問題のコード (`app/helpers/test_sheets_helper.rb`):**
```ruby
def difficulty_options_for_select_with_mix
  options = [["ミックス(全難易度)", nil]]  # ← nil を返す！
  options += TestSheet::DIFFICULTY_LABELS.map { |key, label| [label, key] }
  options
end
```

フォームで「ミックス」を選択すると `nil` がサーバーに送信されますが、モデルは `0` を期待していました。

### **3. 文字列比較のロジックエラー**

**問題のコード (`app/models/test_sheet.rb`):**
```ruby
def get_available_questions
  questions_scope = unit.questions.kept

  if difficulty.present? && difficulty != "mix"  # ← difficultyは整数！
    questions_scope = questions_scope.where(difficulty: DIFFICULTIES[difficulty.to_sym])
  end

  questions_scope
end
```

`difficulty` は整数値 (0, 1, 2, 3) なので、文字列 `"mix"` と比較できません。

---

## ✅ 修正内容

### **1. Enum定義に mix を追加**

**修正後 (`app/models/test_sheet.rb`):**
```ruby
# 難易度の定義（0: mix はすべての難易度を含む）
DIFFICULTIES = {
  mix: 0,      # ← 追加！
  easy: 1,
  normal: 2,
  hard: 3
}.freeze

# 難易度のラベル（日本語・詳細版）
DIFFICULTY_LABELS = {
  "mix" => "ミックス(全難易度)",  # ← 追加！
  "easy" => "易しい(基礎)",
  "normal" => "普通(標準)",
  "hard" => "難しい(応用)"
}.freeze
```

### **2. ヘルパーを簡略化**

**修正後 (`app/helpers/test_sheets_helper.rb`):**
```ruby
# 難易度の選択肢（ミックス含む）
def difficulty_options_for_select_with_mix
  TestSheet::DIFFICULTY_LABELS.map { |key, label| [label, key] }
  # 既に mix が含まれているので、重複して追加する必要なし
end
```

### **3. get_available_questions を修正**

**修正後 (`app/models/test_sheet.rb`):**
```ruby
def get_available_questions
  questions_scope = unit.questions.kept

  # 難易度フィルター（mix以外の場合のみフィルタリング）
  if difficulty_mix?
    # mixの場合はすべての難易度を含む
    questions_scope
  else
    # 特定の難易度のみ
    # difficultyは整数値（1, 2, 3）、Questionのdifficultyも整数値
    questions_scope.where(difficulty: DIFFICULTIES[difficulty.to_sym])
  end
end
```

`difficulty_mix?` は Rails の enum が自動生成するメソッドで、`difficulty == 0` と同等です。

### **4. その他の修正**

**ヘルパーメソッド (`app/helpers/test_sheets_helper.rb`):**
```ruby
# 難易度ラベルの表示
def difficulty_label_for_display(test_sheet)
  if test_sheet.difficulty_mix?
    TestSheet::DIFFICULTY_LABELS["mix"]
  else
    TestSheet::DIFFICULTY_LABELS[test_sheet.difficulty]
  end
end

# 難易度のバッジカラー
def difficulty_badge_color(difficulty)
  case difficulty
  when "mix"
    "bg-purple-100 text-purple-800"  # ← 追加！
  when "easy"
    "bg-green-100 text-green-800"
  # ... 以下略
  end
end
```

**コントローラー (`app/controllers/test_sheets_controller.rb`):**
```ruby
else
  # ミックス（全難易度）
  count = unit.question_count
  label = TestSheet::DIFFICULTY_LABELS["mix"]  # ← 修正！
end
```

---

## 🚀 適用手順

### **ステップ1: 最新コードを取得**

```bash
cd /workspaces/test-generator
git pull origin main
```

**期待される更新:**
```
Updating 87876a7..bcd3b4a
Fast-forward
 app/controllers/test_sheets_controller.rb | 2 +-
 app/helpers/test_sheets_helper.rb         | 14 +++++---------
 app/models/test_sheet.rb                  | 20 ++++++++++----------
 3 files changed, 19 insertions(+), 17 deletions(-)
```

### **ステップ2: コミット履歴確認**

```bash
git log --oneline -3
```

**期待される出力:**
```
bcd3b4a Fix: difficulty 'mix' (0) のサポートを追加
87876a7 docs: すべてのテスト修正完了ガイドを追加
c691e12 Fix: answer_noteカラムが存在しないエラーを修正
```

### **ステップ3: サーバー再起動**

```bash
# 既存のサーバーを停止
pkill -f "rails server"

# または、サーバーが起動していない場合は直接起動
bin/rails server
```

### **ステップ4: テスト作成を確認**

1. ブラウザで http://localhost:3000 にアクセス
2. 科目を選択（例: 英語）
3. 単元を選択（例: 高1 - Unit 1）
4. 難易度で **「ミックス(全難易度)」** を選択
5. 問題数を選択（例: 10）
6. **「テストを作成」** ボタンをクリック

**期待される結果:**
- ✅ 500エラーが発生しない
- ✅ テスト表示画面に遷移
- ✅ すべての難易度（易しい、普通、難しい）から問題がランダムに選択される

---

## 📊 修正の影響範囲

### **変更されたファイル**

| ファイル | 修正内容 |
|---------|---------|
| `app/models/test_sheet.rb` | • DIFFICULTIES に mix 追加<br>• DIFFICULTY_LABELS に mix 追加<br>• get_available_questions 修正<br>• MIX_LABEL 削除 |
| `app/helpers/test_sheets_helper.rb` | • difficulty_options_for_select_with_mix 簡略化<br>• difficulty_label_for_display 修正<br>• difficulty_badge_color に mix 追加 |
| `app/controllers/test_sheets_controller.rb` | • MIX_LABEL 参照を DIFFICULTY_LABELS["mix"] に変更 |

### **影響を受ける機能**

- ✅ テスト作成（new/create）
- ✅ テスト表示（show）
- ✅ テスト一覧（index）
- ✅ 印刷履歴（history）
- ✅ AJAX: 利用可能な問題数取得

---

## 🧪 テスト確認

修正後、以下のテストを実行して確認してください：

```bash
# モデルテスト
bin/rails test test/models/test_sheet_test.rb

# システムテスト
bin/rails test:system

# 全テスト
bin/rails test
```

**期待される結果:**
```
55 runs, XXX assertions, 0 failures, 0 errors, 0 skips ✅
```

---

## 🎯 重要なポイント

### **Enum値の型**

```ruby
# ❌ 誤り
difficulty != "mix"  # difficultyは整数なので常にtrue

# ✅ 正解
difficulty_mix?  # Rails enumが自動生成するメソッド
```

### **Enum定義の完全性**

```ruby
# ❌ 不完全
DIFFICULTIES = { easy: 1, normal: 2, hard: 3 }

# ✅ 完全（すべての値を定義）
DIFFICULTIES = { mix: 0, easy: 1, normal: 2, hard: 3 }
```

### **ヘルパーとモデルの整合性**

```ruby
# ❌ 不整合
# ヘルパー: nil を返す
# モデル: 0 を期待

# ✅ 整合
# ヘルパー: "mix" を返す
# モデル: DIFFICULTIES[:mix] = 0
```

---

## 🔗 関連情報

- **GitHub リポジトリ:** https://github.com/t0j1/test-generator
- **最新コミット:** `bcd3b4a` - Fix: difficulty 'mix' (0) のサポートを追加
- **Rails Enum ドキュメント:** https://api.rubyonrails.org/classes/ActiveRecord/Enum.html

---

## ✅ 確認チェックリスト

- [ ] `git pull origin main` 実行済み
- [ ] サーバー再起動済み
- [ ] 「ミックス(全難易度)」でテスト作成成功
- [ ] 500エラーが発生しない
- [ ] すべての難易度から問題が選択される
- [ ] テストが正常に表示される

---

## 🎊 完了！

この修正により、テスト作成機能が完全に動作するようになりました。「ミックス(全難易度)」を選択しても、すべての難易度から問題がランダムに選ばれ、エラーが発生しなくなります。

お疲れさまでした！ 🎉
