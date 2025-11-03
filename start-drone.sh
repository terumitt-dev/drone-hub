#!/bin/bash
set -e

cd ~/drone-hub

echo "🚀 Drone OSS 更新開始: $(date)"

# 最新設定取得
git pull origin main

# 最新イメージ取得
docker-compose pull

# 再起動
docker-compose up -d

# 不要イメージ削除
docker image prune -f

# 稼働確認
docker ps

echo "✅ Drone OSS 更新・再起動完了: $(date)"
