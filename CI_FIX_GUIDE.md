# CI エラー修正ガイド

## 問題

GitHub Actions CI で以下のエラーが発生しています：

```
The dependencies in your gemfile changed, but the lockfile can't be updated
because frozen mode is set

You have added to the Gemfile:
* discard (~> 1.3)
* bullet
```

## 原因

- `Gemfile`に新しいgem (`discard`, `bullet`) を追加しましたが、`Gemfile.lock`が更新されていません
- GitHub Actionsは`bundler-cache: true`を使用しており、frozen modeで動作します

## 解決方法（ローカル環境で実行）

### 方法1: Gemfile.lockを更新（推奨）

```bash
# 1. リポジトリをクローン/プル
git pull origin main

# 2. bundle installを実行してGemfile.lockを更新
bundle install

# 3. Gemfile.lockをコミット
git add Gemfile.lock
git commit -m "Update Gemfile.lock for new gems (bullet, discard)"
git push origin main
```

### 方法2: CI設定を修正

`.github/workflows/ci.yml`の各ジョブで`bundler-cache`設定を修正します：

**変更前:**
```yaml
- name: Set up Ruby
  uses: ruby/setup-ruby@v1
  with:
    bundler-cache: true
```

**変更後:**
```yaml
- name: Set up Ruby
  uses: ruby/setup-ruby@v1
  with:
    ruby-version: .ruby-version
    bundler-cache: false

- name: Install dependencies
  run: |
    bundle config set frozen false
    bundle install --jobs 4 --retry 3
```

この変更を以下のジョブすべてに適用してください：
- `scan_ruby`
- `scan_js`
- `lint`
- `test`
- `system-test`

## 注意事項

- **方法1が推奨**です（Gemfile.lockを管理することでバージョンを固定）
- 方法2は開発環境では便利ですが、本番環境ではGemfile.lockを管理することを推奨します
- GitHub Appの権限により、サンドボックスからワークフローファイルを直接更新できません

## 確認方法

修正後、GitHub Actionsが正常に動作することを確認：
https://github.com/t0j1/test-generator/actions

すべてのジョブが緑色（成功）になることを確認してください。
