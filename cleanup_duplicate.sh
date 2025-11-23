#!/bin/bash

# test_generatorディレクトリ削除スクリプト
# 使用方法: bash cleanup_duplicate.sh

set -e

echo "=========================================="
echo "test_generator ディレクトリ削除スクリプト"
echo "=========================================="
echo ""

# カレントディレクトリを確認
CURRENT_DIR=$(pwd)
echo "現在のディレクトリ: $CURRENT_DIR"
echo ""

# ルートディレクトリにいることを確認
if [[ ! -f "Gemfile" ]] || [[ ! -f "config.ru" ]] || [[ ! -d "app" ]]; then
    echo "❌ エラー: プロジェクトのルートディレクトリで実行してください"
    echo "   正しいディレクトリ: /workspaces/test-generator"
    exit 1
fi

echo "✅ ルートディレクトリを確認しました"
echo ""

# test_generatorディレクトリが存在するか確認
if [[ ! -d "test_generator" ]]; then
    echo "✅ test_generatorディレクトリは存在しません（すでに削除済み）"
    exit 0
fi

echo "⚠️  test_generatorディレクトリが見つかりました"
echo ""

# ディレクトリの内容を表示
echo "📁 test_generatorディレクトリの内容:"
ls -lh test_generator/ | head -10
echo ""

# Git管理下にあるか確認
GIT_FILES_COUNT=$(git ls-files test_generator/ 2>/dev/null | wc -l)

if [[ $GIT_FILES_COUNT -gt 0 ]]; then
    echo "⚠️  test_generatorディレクトリはGit管理下にあります ($GIT_FILES_COUNT ファイル)"
    echo ""
    echo "実行するコマンド:"
    echo "  git rm -rf test_generator/"
    echo ""
    read -p "削除を実行しますか？ (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️  Gitから削除中..."
        git rm -rf test_generator/
        echo "✅ Gitから削除しました"
        echo ""
        echo "次のステップ:"
        echo "  git commit -m 'Remove duplicate test_generator directory'"
        echo "  git push origin main"
    else
        echo "❌ キャンセルしました"
        exit 1
    fi
else
    echo "ℹ️  test_generatorディレクトリはGit管理下にありません"
    echo ""
    echo "実行するコマンド:"
    echo "  rm -rf test_generator/"
    echo ""
    read -p "削除を実行しますか？ (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️  削除中..."
        rm -rf test_generator/
        echo "✅ 削除しました"
    else
        echo "❌ キャンセルしました"
        exit 1
    fi
fi

echo ""
echo "=========================================="
echo "✅ 完了"
echo "=========================================="
echo ""

# 最終確認
if [[ ! -d "test_generator" ]]; then
    echo "✅ test_generatorディレクトリが削除されました"
    echo ""
    echo "次のステップ:"
    echo "1. Railsが正常に動作するか確認:"
    echo "   bin/rails -v"
    echo ""
    echo "2. テストが正常に実行できるか確認:"
    echo "   bundle install"
    echo "   bin/rails db:test:prepare"
    echo ""
    echo "3. 変更をコミット（Git管理下の場合）:"
    echo "   git status"
    echo "   git commit -m 'Remove duplicate test_generator directory'"
    echo "   git push origin main"
else
    echo "❌ エラー: 削除に失敗しました"
    exit 1
fi
