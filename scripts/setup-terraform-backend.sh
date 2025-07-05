#!/bin/bash

# エラー時にスクリプトを停止
set -e

echo "🔧 Terraform状態管理用のAzure Storage Accountをセットアップしています..."

# 設定
RESOURCE_GROUP_NAME="terraform-state-rg"
STORAGE_ACCOUNT_NAME="tfstatetodoapp"
CONTAINER_NAME="tfstate"
LOCATION="japaneast"

# Azure CLIにログイン
echo "🔐 Azure CLIにログインしています..."
az login

# リソースグループを作成
echo "📦 リソースグループを作成しています..."
az group create \
  --name $RESOURCE_GROUP_NAME \
  --location $LOCATION \
  --tags Environment=infrastructure Project=todo-app ManagedBy=terraform

# ストレージアカウントを作成
echo "💾 ストレージアカウントを作成しています..."
az storage account create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $STORAGE_ACCOUNT_NAME \
  --sku Standard_LRS \
  --encryption-services blob \
  --location $LOCATION \
  --tags Environment=infrastructure Project=todo-app ManagedBy=terraform

# Blobコンテナを作成
echo "📁 Blobコンテナを作成しています..."
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT_NAME

# アクセスキーを取得
echo "🔑 アクセスキーを取得しています..."
ACCOUNT_KEY=$(az storage account keys list \
  --resource-group $RESOURCE_GROUP_NAME \
  --account-name $STORAGE_ACCOUNT_NAME \
  --query '[0].value' \
  --output tsv)

echo "✅ Terraform状態管理のセットアップが完了しました！"
echo ""
echo "📊 作成されたリソース:"
echo "  リソースグループ: $RESOURCE_GROUP_NAME"
echo "  ストレージアカウント: $STORAGE_ACCOUNT_NAME"
echo "  コンテナ: $CONTAINER_NAME"
echo ""
echo "🔑 アクセスキー: $ACCOUNT_KEY"
echo ""
echo "📝 次のステップ:"
echo "1. 環境変数を設定: export ARM_ACCESS_KEY=$ACCOUNT_KEY"
echo "2. dev環境に移動: cd environments/dev"
echo "3. Terraformを初期化: terraform init"
echo "4. プランを確認: terraform plan"
echo "5. デプロイ: terraform apply" 