# 定数一覧ドキュメント（最新版）

**最終更新**: 2025-11-22  
**対応Rails**: 7.1+  
**enum構文**: Rails 7.1 新形式対応済み

このドキュメントは、アプリケーション全体で使用される定数の完全なリファレンスです。

---

## 📋 目次

1. [Question モデル](#question-モデル)
2. [TestSheet モデル](#testsheet-モデル)
3. [Unit モデル](#unit-モデル)
4. [Subject モデル](#subject-モデル)
5. [TestQuestion モデル](#testquestion-モデル)
6. [使用例](#使用例)
7. [メンテナンス時の注意点](#メンテナンス時の注意点)
8. [定数化のメリット](#定数化のメリット)
9. [定数化のベストプラクティス](#定数化のベストプラクティス)

---

## Question モデル

**ファイル**: `app/models/question.rb`

### QUESTION_TYPES
**用途**: 問題タイプの定義（enum）  
**型**: Hash  
**Rails 7.1対応**: `enum :question_type, QUESTION_TYPES`

```ruby
{
  word: 0,           # 単語
  sentence: 1,       # 文章
  calculation: 2     # 計算問題
}
```

**自動生成されるメソッド**:
```ruby
# 判定メソッド
question.word?           # => true/false
question.sentence?       # => true/false
question.calculation?    # => true/false

# 値の取得
Question.question_types  # => {"word"=>0, "sentence"=>1, "calculation"=>2}

# スコープ
Question.word            # => word型の問題のみ取得
Question.sentence        # => sentence型の問題のみ取得
Question.calculation     # => calculation型の問題のみ取得
```

---

### QUESTION_TYPE_LABELS
**用途**: 問題タイプのラベル（日本語表示用）  
**型**: Hash  

```ruby
{
  'word'        => '単語',
  'sentence'    => '文章',
  'calculation' => '計算'
}
```

**使用例**:
```ruby
question.question_type_label  # => '単語'
```

---

### DIFFICULTIES
**用途**: 難易度の定義（enum）  
**型**: Hash  
**Rails 7.1対応**: `enum :difficulty, DIFFICULTIES, prefix: true`

```ruby
{
  easy: 1,    # 易しい
  normal: 2,  # 普通
  hard: 3     # 難しい
}
```

**自動生成されるメソッド（prefix: true付き）**:
```ruby
# 判定メソッド（difficulty_プレフィックス付き）
question.difficulty_easy?       # => true/false
question.difficulty_normal?     # => true/false
question.difficulty_hard?       # => true/false

# 値の取得
Question.difficulties           # => {"easy"=>1, "normal"=>2, "hard"=>3}

# スコープ（difficulty_プレフィックス付き）
Question.difficulty_easy        # => 易しい問題のみ取得
Question.difficulty_normal      # => 普通の問題のみ取得
Question.difficulty_hard        # => 難しい問題のみ取得
```

**なぜ `prefix: true` を使うのか？**:
- `question_type`にもenum値があるため、メソッド名の衝突を防ぐ
- 例: `easy?`ではなく`difficulty_easy?`となり、意図が明確になる

---

### DIFFICULTY_LABELS
**用途**: 難易度のラベル（日本語表示用・シンプル版）  
**型**: Hash  

```ruby
{
  'easy'   => '易しい',
  'normal' => '普通',
  'hard'   => '難しい'
}
```

**使用例**:
```ruby
question.difficulty_label  # => '易しい'
```

---

### DEFAULT_QUESTION_TYPE
**用途**: デフォルトの問題タイプ  
**型**: Symbol  
**値**: `:word`

**使用例**:
```ruby
question.question_type ||= Question::DEFAULT_QUESTION_TYPE
```

---

### DEFAULT_DIFFICULTY
**用途**: デフォルトの難易度  
**型**: Symbol  
**値**: `:easy`

**使用例**:
```ruby
question.difficulty ||= Question::DEFAULT_DIFFICULTY
```

---

## TestSheet モデル

**ファイル**: `app/models/test_sheet.rb`

### DIFFICULTIES
**用途**: 難易度の定義（enum、Question と同じ）  
**型**: Hash  
**Rails 7.1対応**: `enum :difficulty, DIFFICULTIES, prefix: true`

```ruby
{
  easy: 1,
  normal: 2,
  hard: 3
}
```

**自動生成されるメソッド**:
```ruby
# 判定メソッド（prefix: true付き）
test_sheet.difficulty_easy?       # => true/false
test_sheet.difficulty_normal?     # => true/false
test_sheet.difficulty_hard?       # => true/false

# 値の取得
TestSheet.difficulties            # => {"easy"=>1, "normal"=>2, "hard"=>3}

# スコープ
TestSheet.difficulty_easy         # => 易しいテストのみ取得
TestSheet.difficulty_normal       # => 普通のテストのみ取得
TestSheet.difficulty_hard         # => 難しいテストのみ取得
```

---

### DIFFICULTY_LABELS
**用途**: 難易度のラベル（日本語表示用・詳細版）  
**型**: Hash  

```ruby
{
  'easy'   => '易しい(基礎)',
  'normal' => '普通(標準)',
  'hard'   => '難しい(応用)'
}
```

**Question::DIFFICULTY_LABELS との違い**:
- Question: シンプル版（「易しい」「普通」「難しい」）
- TestSheet: 詳細版（レベル説明付き）

**使用例**:
```ruby
test_sheet.difficulty_label  # => '易しい(基礎)'
```

---

### MIX_LABEL
**用途**: ミックス（全難易度）時のラベル  
**型**: String  
**値**: `'ミックス(全難易度)'`

**使用例**:
```ruby
# ビューでの使用
<%= test_sheet.difficulty.nil? ? TestSheet::MIX_LABEL : test_sheet.difficulty_label %>
```

---

### MIN_QUESTION_COUNT
**用途**: 最小問題数  
**型**: Integer  
**値**: `1`

**使用箇所**:
- バリデーション: `validates :question_count, numericality: { greater_than_or_equal_to: MIN_QUESTION_COUNT }`

---

### MAX_QUESTION_COUNT
**用途**: 最大問題数  
**型**: Integer  
**値**: `100`

**使用箇所**:
- バリデーション: `validates :question_count, numericality: { less_than_or_equal_to: MAX_QUESTION_COUNT }`

---

### DEFAULT_QUESTION_COUNT
**用途**: デフォルトの問題数  
**型**: Integer  
**値**: `10`

**使用例**:
```ruby
test_sheet.question_count ||= TestSheet::DEFAULT_QUESTION_COUNT
```

---

### DEFAULT_INCLUDE_HINT
**用途**: ヒント表示のデフォルト値  
**型**: Boolean  
**値**: `false`

**使用例**:
```ruby
test_sheet.include_hint = TestSheet::DEFAULT_INCLUDE_HINT if test_sheet.include_hint.nil?
```

---

### DEFAULT_INCLUDE_ANSWER
**用途**: 解答表示のデフォルト値  
**型**: Boolean  
**値**: `true`

**使用例**:
```ruby
test_sheet.include_answer = TestSheet::DEFAULT_INCLUDE_ANSWER if test_sheet.include_answer.nil?
```

---

### ERROR_INSUFFICIENT_QUESTIONS
**用途**: 問題数不足時のエラーメッセージテンプレート  
**型**: String  
**値**: `'問が不足しています。利用可能: %{available}問、要求: %{requested}問'`

**使用例**:
```ruby
format(
  TestSheet::ERROR_INSUFFICIENT_QUESTIONS,
  available: available_count,
  requested: question_count
)
```

**出力例**:
```
問が不足しています。利用可能: 15問、要求: 20問
```

---

## Unit モデル

**ファイル**: `app/models/unit.rb`

### MIN_GRADE
**用途**: 最小学年  
**型**: Integer  
**値**: `1` （高1）

---

### MAX_GRADE
**用途**: 最大学年  
**型**: Integer  
**値**: `3` （高3）

---

### VALID_GRADES
**用途**: 有効な学年の範囲  
**型**: Range  
**値**: `(1..3)` （高1〜高3）

**使用箇所**:
- バリデーション: `validates :grade, inclusion: { in: VALID_GRADES }`

---

### DIFFICULTY_KEYS
**用途**: 難易度のキー一覧  
**型**: Array  
**値**: `[:easy, :normal, :hard]`

**使用箇所**:
- `question_counts_by_difficulty` メソッド内でループ処理

**使用例**:
```ruby
Unit::DIFFICULTY_KEYS.each do |difficulty|
  counts[difficulty] = questions.send("difficulty_#{difficulty}").count
end
```

---

## Subject モデル

**ファイル**: `app/models/subject.rb`

### DEFAULT_COLORS
**用途**: 科目ごとのデフォルト色  
**型**: Hash  

```ruby
{
  '英語' => '#EF4444',  # 赤
  '数学' => '#3B82F6',  # 青
  '国語' => '#10B981',  # 緑
  '理科' => '#8B5CF6',  # 紫
  '社会' => '#F59E0B'   # オレンジ
}
```

**使用例**:
```ruby
subject.color_code ||= Subject::DEFAULT_COLORS[subject.name]
```

---

## TestQuestion モデル

**ファイル**: `app/models/test_question.rb`

### MIN_QUESTION_ORDER
**用途**: 問題順序の最小値  
**型**: Integer  
**値**: `1`

**使用箇所**:
- バリデーション: `validates :question_order, numericality: { greater_than_or_equal_to: MIN_QUESTION_ORDER }`

---

## 使用例

### 1. フォームで選択肢を表示

```erb
<%# 問題タイプ選択 %>
<%= f.select :question_type, Question.question_type_options_for_select %>

<%# 難易度選択（TestSheet用） %>
<%= f.select :difficulty, TestSheet.difficulty_options_for_select %>

<%# 学年選択 %>
<%= f.select :grade, Unit.grade_options_for_select %>
```

---

### 2. ラベルを表示

```erb
<%# ビューで使用 %>
<%= @question.question_type_label %>
<%= @question.difficulty_label %>
<%= @test_sheet.difficulty_label %>
<%= @unit.grade_label %>
```

---

### 3. 定数を直接参照

```ruby
# コントローラーやモデルで使用

# 最大問題数をチェック
if count > TestSheet::MAX_QUESTION_COUNT
  errors.add(:base, "問題数は#{TestSheet::MAX_QUESTION_COUNT}問以下にしてください")
end

# デフォルト値を設定
question.question_type ||= Question::DEFAULT_QUESTION_TYPE
question.difficulty ||= Question::DEFAULT_DIFFICULTY

# ラベルを取得
label = Question::DIFFICULTY_LABELS[difficulty]

# エラーメッセージを生成
error_msg = format(
  TestSheet::ERROR_INSUFFICIENT_QUESTIONS,
  available: 10,
  requested: 20
)
```

---

### 4. enumメソッドの使用（Rails 7.1構文）

```ruby
# Rails 7.1 新構文（定義時）
enum :difficulty, DIFFICULTIES, prefix: true

# 判定メソッド
question.difficulty_easy?       # => true/false

# スコープ
Question.difficulty_easy        # => easy の問題のみ

# 値の取得
Question.difficulties           # => {"easy"=>1, "normal"=>2, "hard"=>3}

# enum値の変更
question.difficulty = :hard
question.save
```

---

## メンテナンス時の注意点

### 1. ラベルを変更する場合
✅ **OK**: `*_LABELS` 定数を変更  
❌ **NG**: 各メソッド内のハードコードを変更

```ruby
# ✅ 正しい変更方法
DIFFICULTY_LABELS = {
  'easy'   => '簡単',  # ラベルを変更
  'normal' => '普通',
  'hard'   => '難しい'
}.freeze

# ❌ 間違った変更方法（10箇所以上変更が必要）
def difficulty_label
  case difficulty
  when 'easy'   then '簡単'  # ここを変更
  when 'normal' then '普通'  # ここも変更
  # ...
  end
end
```

---

### 2. enum の値を変更する場合
⚠️ **警告**: 既存データが壊れるため、enum値は絶対に変更しないこと

```ruby
# ❌ NG（既存データが壊れる）
DIFFICULTIES = {
  easy: 2,    # 値を変更（既存のeasy:1データが読めなくなる）
  normal: 1,
  hard: 3
}.freeze

# ✅ OK（新しい値を追加）
DIFFICULTIES = {
  easy: 1,
  normal: 2,
  hard: 3,
  expert: 4  # 新しい値を追加
}.freeze
```

**enum値変更が必要な場合の手順**:
1. マイグレーションでデータを変換
2. アプリケーションコードを更新
3. 古いデータとの互換性を確認

---

### 3. 制約値を変更する場合
- `MIN_*`, `MAX_*` 定数を変更
- マイグレーションも必要な場合がある

```ruby
# ✅ 問題数の上限を変更
MAX_QUESTION_COUNT = 200  # 100 から 200 に変更

# マイグレーションが必要な場合
# rails g migration ChangeMaxQuestionCountValidation
# app/models/test_sheet.rb の validates も自動で変更される（定数参照のため）
```

---

### 4. 新しい問題タイプを追加する場合

**手順**:
1. `QUESTION_TYPES` に追加
2. `QUESTION_TYPE_LABELS` に日本語追加
3. マイグレーション不要（enum の範囲内なら）
4. Seed データに新タイプの問題を追加

```ruby
# 1. QUESTION_TYPES に追加
QUESTION_TYPES = {
  word: 0,
  sentence: 1,
  calculation: 2,
  listening: 3  # 新しく追加
}.freeze

# 2. QUESTION_TYPE_LABELS に追加
QUESTION_TYPE_LABELS = {
  'word'        => '単語',
  'sentence'    => '文章',
  'calculation' => '計算',
  'listening'   => 'リスニング'  # 新しく追加
}.freeze

# 3. Seed データに追加
Question.create!(
  unit: unit_english_1,
  question_type: :listening,  # 新タイプを使用
  difficulty: :easy,
  question_text: 'Listen and choose...',
  # ...
)
```

---

### 5. Rails 7.1 enum構文への移行時の注意点

**旧構文（Rails 7.0以前）**:
```ruby
enum difficulty: DIFFICULTIES, _prefix: true
```

**新構文（Rails 7.1以降）**:
```ruby
enum :difficulty, DIFFICULTIES, prefix: true
```

**移行時のチェックポイント**:
- `_prefix` → `prefix` に変更
- 第1引数を `:difficulty` のようにシンボルで明示
- 既存のデータに影響なし（DB構造は変わらない）
- 自動生成されるメソッド名も変わらない

---

## 定数化のメリット

### 1. ハードコードゼロ
- マジックナンバー・文字列を排除
- コードの意図が明確

**例**:
```ruby
# ❌ Before（ハードコード）
if count > 100
  errors.add(:base, "問題数は100問以下にしてください")
end

# ✅ After（定数化）
if count > TestSheet::MAX_QUESTION_COUNT
  errors.add(:base, "問題数は#{TestSheet::MAX_QUESTION_COUNT}問以下にしてください")
end
```

---

### 2. 変更が1箇所で完結
- ラベル変更時に1箇所修正するだけ
- 10箇所以上の修正が不要

**例**:
```ruby
# ✅ 定数を変更するだけ
DIFFICULTY_LABELS = {
  'easy' => '初級'  # 「易しい」→「初級」に変更
}.freeze

# 全てのビュー・メソッドで自動反映される
```

---

### 3. タイポ防止
- 定数参照なので IDE の補完が効く
- スペルミスがコンパイル時に検出される

**例**:
```ruby
# ❌ タイポのリスク（実行時まで分からない）
if difficulty == 'norml'  # スペルミス

# ✅ IDEの補完で安全
if difficulty == Question::DIFFICULTIES[:normal]
```

---

### 4. テストしやすい
- 定数を使ったテストが書きやすい
- モックやスタブが不要

**例**:
```ruby
# ✅ テストコードがシンプル
expect(question.difficulty).to eq(Question::DIFFICULTIES[:easy])
expect(TestSheet::MAX_QUESTION_COUNT).to eq(100)
```

---

### 5. ドキュメントとしても機能
- 定数を見れば仕様が分かる
- コメント不要

**例**:
```ruby
# ✅ 定数自体がドキュメント
MIN_QUESTION_COUNT = 1
MAX_QUESTION_COUNT = 100
DEFAULT_QUESTION_COUNT = 10

# コメント不要で仕様が明確
```

---

## 定数化のベストプラクティス

### 1. freeze を必ず付ける

```ruby
# ✅ Good（破壊的変更を防ぐ）
DIFFICULTIES = { easy: 1 }.freeze

# ❌ Bad（破壊的変更が可能）
DIFFICULTIES = { easy: 1 }

# 破壊的変更の例（freezeがない場合）
DIFFICULTIES[:easy] = 999  # 意図しない変更が可能
```

---

### 2. モデルに密結合な定数はモデル内に定義

```ruby
# ✅ Good（定数とモデルが同じファイル）
class Question < ApplicationRecord
  DIFFICULTIES = { easy: 1, normal: 2, hard: 3 }.freeze
  
  enum :difficulty, DIFFICULTIES, prefix: true
end

# ❌ Bad（別ファイルに分離）
# config/constants/question_constants.rb
QUESTION_DIFFICULTIES = { easy: 1, normal: 2, hard: 3 }

# app/models/question.rb
enum :difficulty, QUESTION_DIFFICULTIES, prefix: true  # 定数が遠い
```

---

### 3. ハッシュのキーは統一

```ruby
# ✅ Good（enum定義はシンボルキー）
DIFFICULTIES = { easy: 1, normal: 2 }.freeze

# ✅ Good（ラベル定義は文字列キー）
DIFFICULTY_LABELS = { 'easy' => '易しい', 'normal' => '普通' }.freeze

# ❌ Bad（混在）
DIFFICULTIES = { 'easy' => 1, normal: 2 }.freeze  # キーの型が不統一
```

**理由**:
- enumはシンボルキーで扱う（Rails標準）
- ラベルは文字列キー（enum値が文字列で返されるため）

---

### 4. 定数名は大文字スネークケース

```ruby
# ✅ Good
MIN_QUESTION_COUNT = 1
DEFAULT_INCLUDE_HINT = false

# ❌ Bad（命名規則違反）
minQuestionCount = 1      # キャメルケース（JS風）
DefaultIncludeHint = false # パスカルケース（クラス名風）
```

---

### 5. 定数の命名規則

| 用途 | 命名パターン | 例 |
|------|-------------|-----|
| enum定義 | 複数形 | `DIFFICULTIES`, `QUESTION_TYPES` |
| ラベル | `*_LABELS` | `DIFFICULTY_LABELS`, `QUESTION_TYPE_LABELS` |
| 最小値 | `MIN_*` | `MIN_QUESTION_COUNT`, `MIN_GRADE` |
| 最大値 | `MAX_*` | `MAX_QUESTION_COUNT`, `MAX_GRADE` |
| デフォルト値 | `DEFAULT_*` | `DEFAULT_QUESTION_COUNT`, `DEFAULT_INCLUDE_HINT` |
| エラー文 | `ERROR_*` | `ERROR_INSUFFICIENT_QUESTIONS` |

---

### 6. エラーメッセージのプレースホルダー

```ruby
# ✅ Good（プレースホルダー使用）
ERROR_INSUFFICIENT_QUESTIONS = '問が不足しています。利用可能: %{available}問、要求: %{requested}問'

format(ERROR_INSUFFICIENT_QUESTIONS, available: 10, requested: 20)
# => "問が不足しています。利用可能: 10問、要求: 20問"

# ❌ Bad（ハードコード）
def error_message
  "問が不足しています。利用可能: #{available_count}問、要求: #{question_count}問"
end
```

---

## 定数の適用範囲と影響

### モデル内定数の影響範囲

| 定数 | 定義場所 | 影響範囲 |
|------|---------|---------|
| `QUESTION_TYPES` | `Question` | モデル、ビュー、ヘルパー、テスト |
| `DIFFICULTY_LABELS` | `Question`, `TestSheet` | ビュー、ヘルパー |
| `MIN_QUESTION_COUNT` | `TestSheet` | モデルバリデーション、ビュー |
| `VALID_GRADES` | `Unit` | モデルバリデーション、シードデータ |
| `DEFAULT_COLORS` | `Subject` | シードデータ、管理画面 |

---

## Rails 7.1 enum構文の完全ガイド

### 基本構文の比較

**Rails 7.0以前**:
```ruby
enum difficulty: { easy: 1, normal: 2, hard: 3 }
enum difficulty: DIFFICULTIES
enum difficulty: DIFFICULTIES, _prefix: true
```

**Rails 7.1以降**:
```ruby
enum :difficulty, { easy: 1, normal: 2, hard: 3 }
enum :difficulty, DIFFICULTIES
enum :difficulty, DIFFICULTIES, prefix: true
```

---

### オプションの変更点

| オプション | Rails 7.0以前 | Rails 7.1以降 |
|-----------|-------------|-------------|
| prefix | `_prefix: true` | `prefix: true` |
| suffix | `_suffix: true` | `suffix: true` |
| scopes | `_scopes: false` | `scopes: false` |
| default | `_default: :easy` | `default: :easy` |

---

### prefix: true を使う理由

```ruby
# prefix なし
enum :status, { active: 0, inactive: 1 }
enum :difficulty, { easy: 1, hard: 3 }

# メソッド名が衝突する可能性
model.active?  # status? difficulty? どっち？

# ✅ prefix: true で解決
enum :status, { active: 0, inactive: 1 }, prefix: true
enum :difficulty, { easy: 1, hard: 3 }, prefix: true

model.status_active?       # 明確
model.difficulty_easy?     # 明確
```

---

## 変更履歴

| 日付 | 変更内容 |
|------|---------|
| 2025-11-22 | Rails 7.1 enum構文対応、定数一覧の完全更新 |
| 2025-11-21 | エラーメッセージ定数化、高校生向けデータ対応 |
| 2025-11-20 | 初版作成 |

---

## 参考リンク

- [Rails 7.1 enum 構文変更](https://edgeguides.rubyonrails.org/7_1_release_notes.html)
- [ActiveRecord::Enum](https://api.rubyonrails.org/classes/ActiveRecord/Enum.html)
- [Ruby Style Guide - Constants](https://rubystyle.guide/#naming-constants)

---

## まとめ

このドキュメントに記載された定数を活用することで、以下のメリットが得られます:

✅ **コード品質向上**: ハードコード削減、タイポ防止  
✅ **保守性向上**: 変更が1箇所で完結  
✅ **開発効率向上**: IDE補完、テストが容易  
✅ **パフォーマンス向上**: enum使用による高速化  
✅ **可読性向上**: 定数名で意図が明確  

定数化は一度実装すれば、その後のメンテナンスコストが劇的に下がります。  
新しい機能を追加する際も、このドキュメントを参照して定数ベースで実装してください。