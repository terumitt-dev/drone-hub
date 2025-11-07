#!/bin/bash
set -e

DRONE_DIR="$HOME/drone-hub"
LOGFILE="/var/log/drone-update.log"

# ✅ ログ出力
exec >> "$LOGFILE" 2>&1

echo "[INFO] Drone 更新開始: $(date)"

# ✅ 必要コマンド確認
for cmd in git docker; do
  if ! command -v $cmd >/dev/null 2>&1; then
    echo "[ERROR] $cmd が見つかりません"
    exit 1
  fi
done

# ✅ docker compose or docker-compose
if docker compose version >/dev/null 2>&1; then
  COMPOSE="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE="docker-compose"
else
  echo "[ERROR] docker compose / docker-compose がありません"
  exit 1
fi

# ✅ ディレクトリ存在確認
if [ ! -d "$DRONE_DIR" ]; then
  echo "[ERROR] $DRONE_DIR が存在しません"
  exit 1
fi

cd "$DRONE_DIR"

# ✅ 更新
git pull origin main
REVISION=$(git rev-parse --short HEAD)
echo "[INFO] 最新コミット: $REVISION"

$COMPOSE pull
$COMPOSE up -d

# ✅ 未使用イメージ削除
docker image prune -f

echo "[INFO] Drone 更新完了: $(date)"
