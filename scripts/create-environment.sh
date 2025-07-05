#!/bin/bash

# エラー時にスクリプトを停止
set -e

# 使用方法の表示
show_usage() {
    echo "使用方法: $0 <environment> [source_environment]"
    echo ""
    echo "引数:"
    echo "  environment        作成する環境名 (例: staging, production)"
    echo "  source_environment コピー元の環境名 (デフォルト: dev)"
    echo ""
    echo "例:"
    echo "  $0 staging"
    echo "  $0 production dev"
    echo "  $0 staging dev"
    exit 1
}

# 引数のチェック
if [ $# -eq 0 ]; then
    echo "❌ エラー: 環境名が指定されていません。"
    show_usage
fi

NEW_ENVIRONMENT=$1
SOURCE_ENVIRONMENT=${2:-dev}

# 環境名の検証
if [[ ! "$NEW_ENVIRONMENT" =~ ^(staging|production)$ ]]; then
    echo "❌ エラー: 無効な環境名です。"
    echo "   有効な環境名: staging, production"
    exit 1
fi

if [[ ! "$SOURCE_ENVIRONMENT" =~ ^(dev|staging|production)$ ]]; then
    echo "❌ エラー: 無効なソース環境名です。"
    echo "   有効なソース環境名: dev, staging, production"
    exit 1
fi

# 同じ環境名の場合はエラー
if [[ "$NEW_ENVIRONMENT" == "$SOURCE_ENVIRONMENT" ]]; then
    echo "❌ エラー: 新しい環境名とソース環境名が同じです。"
    exit 1
fi

echo "🏗️ $NEW_ENVIRONMENT環境を作成しています..."
echo "   コピー元: $SOURCE_ENVIRONMENT"

# ディレクトリパス
SOURCE_DIR="environments/$SOURCE_ENVIRONMENT"
NEW_DIR="environments/$NEW_ENVIRONMENT"

# ソースディレクトリが存在するかチェック
if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "❌ エラー: ソース環境ディレクトリが見つかりません。"
    echo "   $SOURCE_DIR ディレクトリを確認してください。"
    exit 1
fi

# 新しいディレクトリが既に存在するかチェック
if [[ -d "$NEW_DIR" ]]; then
    echo "❌ エラー: $NEW_ENVIRONMENT環境ディレクトリが既に存在します。"
    echo "   $NEW_DIR ディレクトリを削除してから再実行してください。"
    exit 1
fi

# ディレクトリをコピー
echo "📁 ディレクトリをコピーしています..."
cp -r "$SOURCE_DIR" "$NEW_DIR"

# 環境固有の設定を更新
echo "⚙️ 環境固有の設定を更新しています..."

# terraform.tfvarsを更新
sed -i.bak "s/$SOURCE_ENVIRONMENT/$NEW_ENVIRONMENT/g" "$NEW_DIR/terraform.tfvars"
sed -i.bak "s/-$SOURCE_ENVIRONMENT/-$NEW_ENVIRONMENT/g" "$NEW_DIR/terraform.tfvars"

# main.tfのbackend設定を更新
sed -i.bak "s/$SOURCE_ENVIRONMENT.terraform.tfstate/$NEW_ENVIRONMENT.terraform.tfstate/g" "$NEW_DIR/main.tf"

# バックアップファイルを削除
rm -f "$NEW_DIR/terraform.tfvars.bak"
rm -f "$NEW_DIR/main.tf.bak"

echo "✅ $NEW_ENVIRONMENT環境の作成が完了しました！"
echo ""
echo "📝 次のステップ:"
echo "1. $NEW_DIR/terraform.tfvars を確認・編集"
echo "2. 必要に応じてリソース名や設定を調整"
echo "3. プランを確認: ./scripts/plan.sh $NEW_ENVIRONMENT"
echo "4. デプロイ: ./scripts/deploy.sh $NEW_ENVIRONMENT" 