#!/bin/bash
set -e

echo "[INFO] Drone 更新開始: $(date)"

# Drone 起動ディレクトリへ
cd ~/drone-hub

# 最新化
git pull origin main
docker compose pull
docker compose up -d

# 不要イメージ削除（任意）
docker image prune -f

echo "[INFO] Drone 更新完了: $(date)"
docker ps
