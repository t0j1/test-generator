# test_generatorディレクトリ削除ガイド

## 問題

プロジェクトルートに重複した`test_generator`ディレクトリが存在しています：

```
/workspaces/test-generator/
├── app/
├── config/
├── Gemfile
├── test_generator/    # ← 削除対象
│   ├── app/
│   ├── config/
│   ├── Gemfile
│   └── ...
└── ...
```

## 確認方法

### 1. ディレクトリ構造を確認

```bash
cd /workspaces/test-generator
ls -la
```

正しい構造：
```
/workspaces/test-generator/
├── app/
├── bin/
├── config/
├── db/
├── Gemfile
├── Gemfile.lock
├── test/
└── ...
```

### 2. 重複ディレクトリの内容を確認

```bash
# test_generatorディレクトリの内容を確認
ls -la test_generator/

# ルートと比較
diff -r app test_generator/app 2>/dev/null | head -20
```

## 削除手順

### ステップ1: バックアップ（念のため）

```bash
cd /workspaces/test-generator

# ルートディレクトリのGit状態を確認
git status

# test_generatorディレクトリがGit管理下にあるか確認
git ls-files test_generator/
```

### ステップ2: 安全に削除

test_generatorディレクトリがGit管理下にある場合：

```bash
# Gitから削除
git rm -rf test_generator/

# コミット
git commit -m "Remove duplicate test_generator directory"
```

test_generatorディレクトリがGit管理下にない場合：

```bash
# 直接削除
rm -rf test_generator/

# .gitignoreに追加（再作成を防ぐ）
echo "test_generator/" >> .gitignore
git add .gitignore
git commit -m "Remove duplicate test_generator directory and update .gitignore"
```

### ステップ3: 動作確認

```bash
# ディレクトリ構造を確認
ls -la

# Railsが正常に動作するか確認
bin/rails -v

# テストが正常に動作するか確認
bin/rails test:prepare

# サーバー起動テスト
bin/rails server -p 3000 &
sleep 3
curl http://localhost:3000
pkill -f "rails server"
```

### ステップ4: GitHubにプッシュ

```bash
git push origin main
```

## 削除後の確認事項

- [ ] `ls -la`で`test_generator/`ディレクトリが存在しないことを確認
- [ ] `bin/rails -v`が正常に動作することを確認
- [ ] `bin/rails test`が正常に実行できることを確認
- [ ] GitHubにプッシュ済み

## トラブルシューティング

### Q: 削除後にRailsが起動しない

A: ルートディレクトリに必要なファイルがあるか確認：

```bash
# 必須ファイルの確認
ls -la Gemfile config.ru Rakefile bin/rails
```

### Q: Git管理下にあるかわからない

A: 以下のコマンドで確認：

```bash
git ls-files test_generator/ | wc -l
# 0が返ってくればGit管理下にない
```

### Q: 誤って削除した場合

A: Gitから復元：

```bash
git checkout HEAD -- test_generator/
```

## 注意事項

- **必ずルートディレクトリ**（`/workspaces/test-generator`）で作業してください
- **test_generatorディレクトリ内で作業しないでください**
- 削除前に`git status`で状態を確認することを推奨します
- 重要な変更がある場合は、先にコミットしてください

## 参考: 正しいディレクトリ構造

```
/workspaces/test-generator/
├── .git/
├── .github/
│   └── workflows/
│       └── ci.yml
├── app/
│   ├── assets/
│   ├── controllers/
│   ├── helpers/
│   ├── javascript/
│   ├── models/
│   └── views/
├── bin/
├── config/
├── db/
├── lib/
├── log/
├── public/
├── storage/
├── test/
│   ├── controllers/
│   ├── fixtures/
│   ├── models/
│   └── system/
├── tmp/
├── vendor/
├── .gitignore
├── .ruby-version
├── CI_FIX_GUIDE.md
├── Gemfile
├── Gemfile.lock (ローカルで生成)
├── Rakefile
├── README.md
└── config.ru
```
