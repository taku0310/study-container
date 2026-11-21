# 06. Docker Compose

複数のコンテナからなるアプリを **1 つの YAML ファイル** で定義・管理します。
ここでは「Web アプリ（Flask）＋ Redis」のアクセスカウンタを動かします。

```
          :5000
ブラウザ ───────▶ [web] ──"redis:6379"──▶ [redis] ── volume: redis-data
                  └──────── default ネットワーク ────────┘
```

## 1. compose.yaml を読む

[compose.yaml](compose.yaml) を開いて、レッスン 02〜05 で学んだ要素を探してみましょう:

- `build` → 02 の `docker build`
- `ports` → `-p`
- `environment` → `-e`
- `volumes` → 04 のボリューム
- サービス名 `redis` で接続 → 05 のネットワーク（Compose が自動でネットワークを作る）

## 2. 起動

```bash
cd lessons/06-compose
docker compose up -d --build
docker compose ps
```

```bash
curl localhost:5000   # => このページは 1 回表示されました
curl localhost:5000   # => このページは 2 回表示されました
```

## 3. よく使うコマンド

```bash
docker compose logs -f web        # web のログを追う
docker compose exec redis redis-cli get hits   # redis の中を覗く
docker compose restart web        # web だけ再起動
docker compose down               # 停止＆削除（ボリュームは残る）
docker compose up -d
curl localhost:5000               # カウントは続きから！
docker compose down -v            # ボリュームも削除
```

## 4. スケール

```bash
docker compose up -d --scale web=3
```

→ ポート `5000` が衝突してエラーになります。なぜでしょう？
（ヒント: ホストの同じポートを 3 つのコンテナで使おうとしている）

## やってみよう

1. `compose.yaml` に `redis-commander`（`rediscommander/redis-commander:latest`、環境変数 `REDIS_HOSTS=local:redis:6379`、ポート `8081`）を追加して、ブラウザから Redis の中身を見てみよう
2. `web` サービスにバインドマウント（`./web:/app`）を追加し、`app.py` の文言を変えて `docker compose restart web` で反映させよう
3. スケール時のポート衝突を解消しよう

<details>
<summary>解答例</summary>

1.
```yaml
  redis-commander:
    image: rediscommander/redis-commander:latest
    environment:
      REDIS_HOSTS: local:redis:6379
    ports:
      - "8081:8081"
    depends_on:
      - redis
```

2.
```yaml
  web:
    build: ./web
    volumes:
      - ./web:/app
```

3. `ports: ["5000"]` のようにホスト側ポートを省略するとランダムなポートが割り当てられます（`docker compose ps` で確認）。
   実運用では前段に nginx などのロードバランサを置き、web 側はポートを公開しないのが一般的です。
</details>
