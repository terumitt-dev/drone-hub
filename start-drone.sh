#!/bin/bash
set -e

DRONE_DIR="$HOME/drone-hub"
LOGFILE="$HOME/drone-update.log"

# ====== ログ ======
exec >> "$LOGFILE" 2>&1
echo "[INFO] ===== Drone 更新開始: $(date) ====="

# ====== 前提コマンド ======
for cmd in git docker; do
  if ! command -v $cmd >/dev/null 2>&1; then
    echo "[ERROR] $cmd が見つかりません"
    exit 1
  fi
done

# docker compose / docker-compose
if docker compose version >/dev/null 2>&1; then
  COMPOSE="docker compose"
else
  COMPOSE="docker-compose"
fi
echo "[INFO] 使用 compose: $COMPOSE"

# ====== リポジトリ移動 ======
if [ ! -d "$DRONE_DIR" ]; then
  echo "[ERROR] $DRONE_DIR が存在しません"
  exit 1
fi
cd "$DRONE_DIR"

# ====== 更新 ======
git pull
REVISION=$(git rev-parse --short HEAD)
echo "[INFO] 最新コミット: $REVISION"

$COMPOSE pull
$COMPOSE up -d

# ====== 終了 ======
echo "[INFO] ===== Drone 更新完了: $(date) ====="
