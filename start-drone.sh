#!/bin/bash
set -e

# リポジトリディレクトリに移動
cd ~/drone-hub

# 最新の設定を取得
git pull origin main

# Dockerイメージを最新化
docker-compose pull

# コンテナ起動
docker-compose up -d

# 状況確認
docker ps

echo "Drone OSS 起動・更新完了 🚀"
