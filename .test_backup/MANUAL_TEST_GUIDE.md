# 手動テストガイド

## 🎯 目的

このガイドでは、`style="display: none;"` から `class="hidden"` への修正が正しく機能するか、ブラウザで手動確認する方法を説明します。

---

## 📁 テストファイル

### test_manual_check.html

このHTMLファイルは、修正前と修正後の動作を比較できるスタンドアロンのテストページです。

**場所:** `/home/user/webapp/test_manual_check.html`

---

## 🚀 テスト実行方法

### 方法1: ブラウザで直接開く

```bash
# ファイルマネージャーでファイルを右クリック → ブラウザで開く
# または
open test_manual_check.html  # macOS
xdg-open test_manual_check.html  # Linux
```

### 方法2: ローカルサーバーを起動

```bash
# Pythonを使用
cd /home/user/webapp
python3 -m http.server 8000

# ブラウザで開く
# → http://localhost:8000/test_manual_check.html
```

### 方法3: VS Codeの Live Server

1. VS Codeで `test_manual_check.html` を開く
2. 右クリック → "Open with Live Server"

---

## 🧪 テストケース

### テスト1: 修正前の動作（バグ再現）

1. ページを開く
2. **「科目を選択（修正前の動作）」** ボタンをクリック
3. **結果:** 単元選択セクションが表示されない（❌ 表示失敗）
4. **理由:** インラインスタイル `style="display: none;"` が優先される

### テスト2: 修正後の動作（正常動作）

1. **「科目を選択（修正後の動作）」** ボタンをクリック
2. **結果:** 単元選択セクションが表示される（✅ 表示成功）
3. **理由:** Tailwind `hidden` クラスが正常に削除される

### テスト3: Stimulusコントローラー

1. **科目選択**（英語 or 数学）のラジオボタンをクリック
2. **結果:** 単元選択セクションが動的に表示される
3. **確認:** コンソールログで「📌 Subject changed」が表示される

---

## 📊 テスト結果の見方

### ページ上部の「テスト結果」セクション

自動的に各テストの結果が表示されます:

```
✅ ページ読み込み
   テストページが正常に読み込まれました

✅ Stimulusコントローラー接続
   コントローラーが正常に登録・接続されました

✅ 修正後の実装
   classList.remove("hidden") が正常に動作し、要素が表示されました

❌ 修正前の実装
   インラインスタイルが優先され、classList.remove("hidden") が効果なし
```

---

## 🔍 ブラウザコンソールでの確認

### F12 → Console

以下のログが表示されるはずです:

```
✅ Test page loaded
✅ TestFormDemo controller connected
📌 Subject changed: english
```

### 要素の検証

1. F12 → Elements（要素）タブ
2. 単元選択セクションを探す
3. **修正前:**
   ```html
   <div id="unit-section-before" style="display: none;" class="...">
   ```
   → `style="display: none;"` が残っている

4. **修正後:**
   ```html
   <div id="unit-section-after" class="border-2 border-gray-300 p-4 rounded">
   ```
   → `hidden` クラスが削除され、`style` 属性が無い

---

## ✅ 期待される動作

### 修正前（バグ）

```
[科目を選択ボタン] → クリック
↓
JavaScript: classList.remove("hidden") 実行
↓
❌ インラインスタイル style="display: none;" が優先される
↓
❌ 単元選択セクションは表示されない
```

### 修正後（正常）

```
[科目を選択ボタン] → クリック
↓
JavaScript: classList.remove("hidden") 実行
↓
✅ hidden クラスが削除される
↓
✅ 単元選択セクションが表示される
```

---

## 🎓 技術的な理解

### CSS優先順位

1. **インラインスタイル（最優先）** - `style="..."`
2. ID セレクタ - `#id`
3. クラスセレクタ - `.class`
4. 要素セレクタ - `div`

### なぜ修正が必要だったか？

**修正前:**
```html
<div style="display: none;" class="hidden" ...>
```

JavaScriptで `classList.remove("hidden")` を実行しても、インラインスタイルの `display: none;` が最優先されるため表示されない。

**修正後:**
```html
<div class="hidden" ...>
```

JavaScriptで `classList.remove("hidden")` を実行すると、クラスが削除され、デフォルトの表示状態（`display: block` など）になる。

---

## 🐛 デバッグ方法

### 問題が再発した場合

1. **F12 → Console** でエラーを確認
2. **Elements** タブで要素を検証
   - `style="display: none;"` が付いていないか確認
   - `hidden` クラスが正しく削除されているか確認
3. **Computed** タブで最終的なスタイルを確認
   - `display: none` になっていないか確認

### よくある問題

| 症状 | 原因 | 解決方法 |
|------|------|----------|
| 単元が表示されない | インラインスタイルが残っている | `style="..."` を削除 |
| Stimulusが動作しない | コントローラーが接続されていない | コンソールログを確認 |
| hiddenクラスが削除されない | JavaScriptエラー | F12でエラーログを確認 |

---

## 📋 チェックリスト

実際のRailsアプリで確認する際のチェックリスト:

```
□ サーバー起動: bin/rails server
□ ブラウザで開く: http://localhost:3000
□ F12 → Console → "✅ TestFormController connected" 表示
□ 科目をクリック → 単元リストが動的に表示される
□ Elements タブで確認:
  □ data-test-form-target="unitSection" に style="display: none;" が無い
  □ class="... hidden" がある（初期状態）
  □ クリック後に hidden クラスが削除される
□ 単元を選択 → 設定セクションが表示される
□ 難易度を変更 → 利用可能問題数が更新される
□ テスト作成 → show画面に遷移
```

---

## 🎉 成功の確認

全てのテストが以下の状態なら成功:

```
✅ ページ読み込み成功
✅ Stimulusコントローラー接続
✅ 修正前の実装でバグ再現（期待通り）
✅ 修正後の実装で正常動作
✅ Stimulus制御で動的表示
```

**テストページのURL:**
- ローカル: `file:///home/user/webapp/test_manual_check.html`
- HTTP Server: `http://localhost:8000/test_manual_check.html`

---

## 📚 関連ドキュメント

- **TEST_RESULTS.md** - 全体的なテスト結果レポート
- **test/javascript/test_form_controller.test.js** - JavaScriptユニットテスト
- **test/system/test_sheet_creation_test.rb** - システムテスト
- **test/controllers/test_sheets_controller_test.rb** - コントローラーテスト
