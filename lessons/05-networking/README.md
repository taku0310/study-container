# 05. ネットワーク

コンテナ同士はどうやって通信するのでしょうか。

## 1. ネットワークの一覧

```bash
docker network ls
# bridge / host / none がデフォルトで存在する
```

| ドライバ | 説明 |
|----------|------|
| `bridge` | デフォルト。コンテナごとに仮想 IP が振られる |
| `host` | ホストのネットワークをそのまま使う |
| `none` | ネットワークなし |

## 2. ユーザー定義ネットワークを作る

```bash
docker network create mynet

# サーバー役
docker run -d --name api --network mynet nginx:1.27-alpine

# クライアント役: コンテナ名 "api" で名前解決できる！
docker run --rm --network mynet alpine:3.20 wget -qO- http://api | head -4
```

> **ポイント**: ユーザー定義ネットワークでは Docker 内蔵の DNS が動き、
> **コンテナ名がそのままホスト名** になります。IP アドレスを気にする必要はありません。

## 3. デフォルト bridge との違い

```bash
docker run -d --name api2 nginx:1.27-alpine   # --network 指定なし = デフォルト bridge
docker run --rm alpine:3.20 wget -qO- -T 3 http://api2
# => bad address 'api2'  (デフォルト bridge では名前解決できない)
```

## 4. ネットワークによる隔離

```bash
docker network create othernet
docker run --rm --network othernet alpine:3.20 wget -qO- -T 3 http://api
# => bad address 'api'  (別ネットワークからは見えない)
```

フロントエンド用・DB 用でネットワークを分けると、DB を外部から隔離できます。

## 5. IP を確認する

```bash
docker network inspect mynet --format '{{range .Containers}}{{.Name}} {{.IPv4Address}}{{"\n"}}{{end}}'
```

## 6. 後片付け

```bash
docker rm -f api api2
docker network rm mynet othernet
```

## やってみよう

1. `redis:7-alpine` を `mynet` 上で `cache` という名前で起動し、別コンテナから `redis-cli -h cache ping` で `PONG` を返してもらおう
2. 起動中のコンテナを後から別ネットワークに接続する `docker network connect` を試そう

<details>
<summary>解答例</summary>

```bash
docker network create mynet
docker run -d --name cache --network mynet redis:7-alpine
docker run --rm --network mynet redis:7-alpine redis-cli -h cache ping   # => PONG

docker network create othernet
docker network connect othernet cache   # cache は2つのネットワークに所属
docker run --rm --network othernet redis:7-alpine redis-cli -h cache ping   # => PONG

docker rm -f cache && docker network rm mynet othernet
```
</details>

次のレッスンでは、ここまで手作業でやったこと（ネットワーク作成・複数コンテナ起動）を Docker Compose で自動化します。
