#!/bin/bash
set -e

# UTF-8 環境を前提
export LANG=en_US.UTF-8

# ====== 前提チェック ======
for cmd in git docker-compose docker; do
  if ! command -v $cmd &>/dev/null; then
    echo "[ERROR] $cmd が見つかりません。"
    exit 1
  fi
done

if [ ! -d ~/drone-hub ]; then
  echo "[ERROR] ~/drone-hub ディレクトリが存在しません。"
  exit 1
fi

# ====== 実行 ======
cd ~/drone-hub

echo "[INFO] Drone OSS 更新開始: $(date)"

git pull origin main
docker-compose pull
docker-compose up -d

# 安全なクリーンアップ
read -p "[INFO] 不要イメージを削除しますか？ (y/N): " confirm
if [ "$confirm" = "y" ]; then
  docker image prune -f
fi

docker ps
echo "[INFO] Drone OSS 更新・再起動完了: $(date)"
