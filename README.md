# Drone Hub

Drone CI/CD サーバー + Runner の管理リポジトリ。
Docker Compose で Drone OSS を運用しています。

外部からのアクセスは Cloudflare Tunnel (cloudflared) 経由で受けており、
EC2 のインバウンドポート (80/443) は閉じたまま運用しています。

## 構成

| コンポーネント | イメージ | 役割 |
|---|---|---|
| drone-server | `drone/drone:2` | CI/CD サーバー（Web UI + API） |
| drone-runner | `drone/drone-runner-docker:1` | ビルド実行（Docker Runner, capacity: 2） |
| cloudflared | `cloudflare/cloudflared:latest` | Cloudflare Tunnel コネクタ（外部 HTTPS → 内部 HTTP に終端） |

## セットアップ

### 1. EC2 インスタンスを用意

Ubuntu にて Docker と Docker Compose をインストール済みのインスタンスを準備。

### 2. リポジトリをクローン

```bash
cd ~
git clone git@github.com:terumitt-dev/drone-hub.git
cd drone-hub
```

### 3. `.env` を作成

```bash
cp .env.example .env
vi .env
```

必要な環境変数：

| 変数 | 説明 |
|---|---|
| `DRONE_SERVER_HOST` | Drone のホスト名（例: `drone.go-lilaregard.com`） |
| `DRONE_SERVER_PROTO` | プロトコル（`https`。Cloudflare 側で TLS 終端） |
| `DRONE_GITHUB_CLIENT_ID` | GitHub OAuth Client ID |
| `DRONE_GITHUB_CLIENT_SECRET` | GitHub OAuth Client Secret |
| `DRONE_RPC_SECRET` | Server-Runner 間の共有シークレット |
| `DRONE_ADMIN` | 管理者の GitHub ユーザー名 |
| `CLOUDFLARE_TUNNEL_TOKEN` | Cloudflare Tunnel コネクタ用トークン |

### 4. Cloudflare Tunnel の設定

Cloudflare ダッシュボードで Tunnel を作成し、Public Hostname を設定する。

1. Zero Trust → Networks → Tunnels → **Create a tunnel** → Cloudflared を選択
2. Tunnel 名（例: `drone-prod`）を入力 → Save
3. 表示される `--token eyJh...` を控えて `.env` の `CLOUDFLARE_TUNNEL_TOKEN` に設定
4. **Public Hostnames** タブで以下を追加:
   - Subdomain: `drone`
   - Domain: `go-lilaregard.com`
   - Service: `HTTP` / `drone-server:80`
5. Cloudflare DNS に CNAME (`drone` → `<tunnel-id>.cfargotunnel.com`) が自動作成されることを確認

### 5. 起動

```bash
./start-drone.sh
```

### 6. 確認

ブラウザで `https://<DRONE_SERVER_HOST>` にアクセスして Drone UI を確認。

## 更新

リポジトリに変更を加えた後、サーバーに SSH して適用：

```bash
ssh drone-server
cd ~/drone-hub
git pull
docker compose pull
docker compose up -d
```

または `start-drone.sh` を実行：

```bash
./start-drone.sh
```

## メンテナンス

### Docker リソースの定期クリーンアップ

Drone の CI/CD ビルドにより Docker イメージ・ボリュームが蓄積し、ディスクを圧迫します。
以下の crontab を設定して自動クリーンアップしてください。

```bash
crontab -e
```

追加する行：

```
# 毎週日曜 3時に1週間以上古い Docker リソースを削除
0 3 * * 0 docker system prune -af --volumes --filter "until=168h" >> /var/log/docker-prune.log 2>&1
```

#### 手動クリーンアップ

```bash
# 使用状況の確認
docker system df

# 即時クリーンアップ
docker system prune -a --volumes
```

## ファイル構成

```
drone-hub/
├── docker-compose.yml    # Drone Server + Runner + cloudflared 定義
├── .env.example          # 環境変数テンプレート
├── .env                  # 環境変数（gitignore）
├── start-drone.sh        # 起動・更新スクリプト
├── data/                 # Drone データ（gitignore）
└── .github/workflows/    # GitHub Actions（レビュー自動化）
```
