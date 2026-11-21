# 04. データの永続化（ボリューム）

コンテナは **使い捨て** が前提です。削除すると中のデータも消えます。
データを残すには、コンテナの外にデータを置く仕組みを使います。

| 種類 | 書き方 | 用途 |
|------|--------|------|
| 名前付きボリューム | `-v mydata:/data` | DB のデータなど。Docker が管理する |
| バインドマウント | `-v $(pwd)/html:/usr/share/nginx/html` | 開発時にホストのソースを直接反映 |
| tmpfs | `--tmpfs /tmp` | メモリ上の一時領域 |

## 1. データが消えることを確認

```bash
docker run --name note alpine:3.20 sh -c 'echo "大事なメモ" > /memo.txt'
docker rm note
docker run --rm alpine:3.20 cat /memo.txt
# => No such file or directory
```

## 2. 名前付きボリューム

```bash
docker volume create notes
docker run --rm -v notes:/data alpine:3.20 sh -c 'echo "大事なメモ" >> /data/memo.txt'
docker run --rm -v notes:/data alpine:3.20 sh -c 'echo "2つ目のメモ" >> /data/memo.txt'

# 別のコンテナからでも読める
docker run --rm -v notes:/data alpine:3.20 cat /data/memo.txt

docker volume ls
docker volume inspect notes   # Mountpoint にホスト側の実体の場所が出る
```

コンテナは毎回 `--rm` で消していますが、データは残っています。

## 3. バインドマウント（開発で便利）

```bash
cd lessons/04-volumes
mkdir -p html
echo '<h1>Version 1</h1>' > html/index.html

docker run -d --name devweb -p 8080:80 \
  -v "$(pwd)/html:/usr/share/nginx/html:ro" nginx:1.27-alpine
curl localhost:8080

# ホスト側のファイルを書き換えると…
echo '<h1>Version 2</h1>' > html/index.html
curl localhost:8080   # 再ビルドなしで反映される
```

`:ro` を付けるとコンテナからは読み取り専用になります。

```bash
docker rm -f devweb
rm -rf html
```

## 4. 後片付け

```bash
docker volume rm notes
docker volume prune   # 使われていないボリュームをまとめて削除
```

## やってみよう

1. `postgres:16-alpine` をボリューム付きで起動してテーブルを作り、コンテナを削除→再作成してもデータが残ることを確認しよう

<details>
<summary>解答例</summary>

```bash
docker run -d --name pg -e POSTGRES_PASSWORD=pass -v pgdata:/var/lib/postgresql/data postgres:16-alpine
sleep 5
docker exec pg psql -U postgres -c "CREATE TABLE t(x int); INSERT INTO t VALUES (42);"
docker rm -f pg

docker run -d --name pg -e POSTGRES_PASSWORD=pass -v pgdata:/var/lib/postgresql/data postgres:16-alpine
sleep 5
docker exec pg psql -U postgres -c "SELECT * FROM t;"   # => 42
docker rm -f pg && docker volume rm pgdata
```
</details>
