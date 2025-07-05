#!/bin/bash

# エラー時にスクリプトを停止
set -e

# 使用方法の表示
show_usage() {
    echo "使用方法: $0 <environment>"
    echo ""
    echo "引数:"
    echo "  environment    破棄する環境名 (例: dev, staging, production)"
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

echo "🗑️ $ENVIRONMENT環境のインフラを破棄しています..."

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

# 破棄プランの確認
echo "📋 破棄プランを確認しています..."
terraform plan -destroy

# ユーザーに確認
echo ""
echo "⚠️  警告: この操作により、$ENVIRONMENT環境のすべてのリソースが削除されます。"
echo "   削除されるリソース:"
echo "   - リソースグループ"
echo "   - ストレージアカウント"
echo "   - Container Registry"
echo "   - Container Apps"
echo "   - データベース"
echo "   - Front Door"
echo "   - 仮想ネットワーク"
echo ""

# production環境の場合は特別な確認
if [[ "$ENVIRONMENT" == "production" ]]; then
    echo "🚨 本番環境の破棄です。特に注意してください！"
    read -p "本当に本番環境を破棄しますか？ (yes/no): " -r
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        echo "❌ 破棄がキャンセルされました。"
        exit 1
    fi
else
    read -p "本当に$ENVIRONMENT環境を破棄しますか？ (yes/no): " -r
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        echo "❌ 破棄がキャンセルされました。"
        exit 1
    fi
fi

# 破棄の実行
echo "🗑️ インフラを破棄しています..."
terraform destroy -auto-approve

echo "✅ $ENVIRONMENT環境の破棄が完了しました！" 