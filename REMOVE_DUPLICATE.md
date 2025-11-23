# test_generator ディレクトリ削除手順

## 🎯 概要

`/workspaces/test-generator/test_generator/` という重複ディレクトリを削除します。

## ⚡ クイックスタート（推奨）

```bash
cd /workspaces/test-generator
bash cleanup_duplicate.sh
```

このスクリプトが自動的に：
- ✅ ルートディレクトリにいることを確認
- ✅ Git管理下かどうかを確認
- ✅ 安全に削除を実行

## 🔧 手動削除（代替方法）

### 方法1: Git管理下の場合

```bash
cd /workspaces/test-generator

# Gitから削除
git rm -rf test_generator/

# コミット
git commit -m "Remove duplicate test_generator directory"

# プッシュ
git push origin main
```

### 方法2: Git管理外の場合

```bash
cd /workspaces/test-generator

# 直接削除
rm -rf test_generator/
```

## ✅ 削除後の確認

```bash
# 1. ディレクトリが削除されたことを確認
ls -la test_generator/  # "No such file or directory" が表示されればOK

# 2. Railsが正常に動作するか確認
bin/rails -v

# 3. bundle installを実行
bundle install

# 4. テストデータベースをセットアップ
bin/rails db:test:prepare

# 5. サーバーを起動してみる
bin/rails server
```

## 📂 正しいディレクトリ構造

削除後、以下の構造になるはずです：

```
/workspaces/test-generator/
├── app/
├── bin/
├── config/
├── db/
├── test/
├── Gemfile
├── Gemfile.lock
└── ...
```

## 🚨 トラブルシューティング

### Q: "Permission denied" エラーが出る

```bash
# 管理者権限で削除
sudo rm -rf test_generator/
```

### Q: 削除後にRailsが動かない

```bash
# 必須ファイルがあるか確認
ls -la Gemfile config.ru Rakefile bin/rails

# bundle installを再実行
bundle install
```

### Q: Git管理下かわからない

```bash
# 確認コマンド
git ls-files test_generator/ | wc -l
# 0が表示されればGit管理外
```

## 📝 注意事項

- ⚠️ **必ず**ルートディレクトリ（`/workspaces/test-generator`）で実行してください
- ⚠️ `test_generator/`内で作業しないでください
- ⚠️ 削除前に重要な変更があればコミットしてください

## 🔗 関連ファイル

- 詳細ガイド: `CLEANUP_GUIDE.md`
- 自動削除スクリプト: `cleanup_duplicate.sh`
