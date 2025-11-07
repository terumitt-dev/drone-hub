#!/bin/bash
set -e

DRONE_DIR="$HOME/drone-hub"
LOGFILE="$HOME/drone-update.log"

# ====== ログ出力 ======
exec >> "$LOGFILE" 2>&1
echo "[INFO] ===== Drone 更新開始: $(date) ====="

# ====== 前提コマンド ======
REQUIRED_CMDS=(git docker)
for cmd in "${REQUIRED_CMDS[@]}"; do
  if ! command -v $cmd >/dev/null 2>&1; then
    echo "[ERROR] $cmd が見つかりません"
    exit 1
  fi
done

# ====== compose 判定 ======
if docker compose version >/dev/null 2>&1; then
  COMPOSE="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE="docker-compose"
else
  echo "[ERROR] docker compose / docker-compose が見つかりません"
  exit 1
fi
echo "[INFO] 使用 compose: $COMPOSE"

# ====== repo チェック ======
if [ ! -d "$DRONE_DIR" ]; then
  echo "[ERROR] $DRONE_DIR が存在しません"
  exit 1
fi

cd "$DRONE_DIR"

if [ ! -d .git ]; then
  echo "[ERROR] $DRONE_DIR は git リポジトリではありません"
  exit 1
fi

# origin main があるか確認（任意）
if ! git ls-remote --exit-code origin main >/dev/null 2>&1; then
  echo "[WARN] origin main が存在しません"
fi

# ====== 更新 ======
git pull origin main
REVISION=$(git rev-parse --short HEAD)
echo "[INFO] 最新コミット: $REVISION"

$COMPOSE pull
$COMPOSE up -d

docker image prune -f

echo "[INFO] ===== Drone 更新完了: $(date) ====="
