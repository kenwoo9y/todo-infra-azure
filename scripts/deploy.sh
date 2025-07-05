#!/bin/bash

# エラー時にスクリプトを停止
set -e

# 使用方法の表示
show_usage() {
    echo "使用方法: $0 <environment>"
    echo ""
    echo "引数:"
    echo "  environment    デプロイする環境名 (例: dev, staging, production)"
    echo ""
    echo "例:"
    echo "  $0 dev"
    echo "  $0 staging"
    echo "  $0 production"
    exit 1
}

# 引数のチェック
if [ $# -eq 0 ]; then
    echo "❌ エラー: 環境名が指定されていません。"
    show_usage
fi

ENVIRONMENT=$1

# 環境名の検証
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|production)$ ]]; then
    echo "❌ エラー: 無効な環境名です。"
    echo "   有効な環境名: dev, staging, production"
    exit 1
fi

echo "🚀 $ENVIRONMENT環境のインフラをデプロイしています..."

# 環境ディレクトリのパス
ENV_DIR="environments/$ENVIRONMENT"

# 環境ディレクトリが存在するかチェック
if [[ ! -d "$ENV_DIR" ]] || [[ ! -f "$ENV_DIR/main.tf" ]] || [[ ! -f "$ENV_DIR/variables.tf" ]]; then
    echo "❌ エラー: $ENVIRONMENT環境ディレクトリまたは必要なファイルが見つかりません。"
    echo "   $ENV_DIR ディレクトリを確認してください。"
    exit 1
fi

# 環境ディレクトリに移動
cd "$ENV_DIR"

# Terraformの初期化
echo "📦 Terraformを初期化しています..."
terraform init

# プランの確認
echo "📋 デプロイプランを確認しています..."
terraform plan

# ユーザーに確認
read -p "$ENVIRONMENT環境にデプロイを続行しますか？ (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ デプロイがキャンセルされました。"
    exit 1
fi

# デプロイの実行
echo "🏗️ インフラをデプロイしています..."
terraform apply -auto-approve

# デプロイ完了
echo "✅ $ENVIRONMENT環境のデプロイが完了しました！"
echo ""
echo "📊 デプロイ結果:"
terraform output

echo ""
echo "🔗 アクセスURL:"
echo "Front Door URL: https://$(terraform output -raw front_door_url)"
echo "Container App URL: https://$(terraform output -raw container_app_url)"
echo "Storage Account Web Endpoint: $(terraform output -raw storage_account_primary_web_endpoint)"

echo ""
echo "📝 次のステップ:"
echo "1. アプリケーションのDockerイメージをContainer Registryにプッシュ"
echo "2. フロントエンドアプリケーションをBlob Storageにアップロード"
echo "3. Container Appを更新して新しいイメージをデプロイ" 