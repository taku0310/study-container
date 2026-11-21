# study-container

コンテナ（Docker）を **手を動かしながら** 学ぶためのハンズオン教材です。
各レッスンは独立していて、上から順に進めると基礎から Docker Compose・ベストプラクティスまで一通り身につきます。

## 前提

- Docker Engine / Docker Desktop がインストール済み（`docker version` で確認）
- Docker Compose v2（`docker compose version` で確認）

## レッスン一覧

| # | テーマ | 学べること |
|---|--------|-----------|
| [01](lessons/01-basics/) | コンテナの基本操作 | `run` / `ps` / `exec` / `logs` / `stop` / `rm`、イメージとコンテナの違い |
| [02](lessons/02-dockerfile/) | Dockerfile を書く | `FROM` / `COPY` / `RUN` / `CMD`、ビルド、ポート公開、レイヤーキャッシュ |
| [03](lessons/03-multistage/) | マルチステージビルド | ビルド環境と実行環境の分離、イメージサイズ削減、`.dockerignore` |
| [04](lessons/04-volumes/) | データの永続化 | 名前付きボリューム、バインドマウント、コンテナの使い捨て性 |
| [05](lessons/05-networking/) | ネットワーク | ユーザー定義ネットワーク、コンテナ名による名前解決 |
| [06](lessons/06-compose/) | Docker Compose | 複数コンテナ構成（Web + Redis）を 1 ファイルで管理 |
| [07](lessons/07-best-practices/) | ベストプラクティス | 非 root 実行、HEALTHCHECK、環境変数、イメージの固定 |

## 進め方

1. 各レッスンの `README.md` を読み、コマンドを **自分で打って** 実行する
2. 「やってみよう」の課題に取り組む
3. 詰まったら `<details>` の解答例を開く

## 便利コマンド集

```bash
docker ps -a                 # すべてのコンテナ
docker images                # イメージ一覧
docker system df             # ディスク使用量
docker system prune          # 停止中コンテナ・未使用データを掃除
```

全レッスンの動作確認は `./scripts/check-all.sh` で行えます。
