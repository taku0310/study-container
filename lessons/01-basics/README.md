# 01. コンテナの基本操作

## キーワード

- **イメージ**: アプリと実行環境をまとめた「設計図」（読み取り専用）
- **コンテナ**: イメージから起動した「実体（プロセス）」。同じイメージからいくつでも作れる

```
イメージ (nginx:1.27-alpine) ──run──▶ コンテナA
                              ──run──▶ コンテナB
```

## 1. 初めてのコンテナ

```bash
docker run hello-world
```

ローカルにイメージがなければ Docker Hub から自動で取得（pull）し、コンテナを起動します。

## 2. 対話的にコンテナに入る

```bash
docker run -it --rm alpine:3.20 sh
```

- `-i` 標準入力を開いたまま / `-t` 端末を割り当て
- `--rm` 終了したらコンテナを自動削除

中で試してみましょう:

```sh
cat /etc/os-release   # ホストとは違う OS (Alpine) に見える
ps aux                # プロセスが sh と ps しかない = 隔離されている
hostname              # コンテナ ID がホスト名になっている
exit
```

## 3. バックグラウンドで動かす

```bash
docker run -d --name web -p 8080:80 nginx:1.27-alpine
```

- `-d` バックグラウンド実行（detached）
- `--name` コンテナに名前を付ける
- `-p ホスト側:コンテナ側` ポートを公開

```bash
curl http://localhost:8080   # nginx のページが返る
docker ps                    # 動いているコンテナ一覧
docker logs web              # ログ（curl したアクセスログが見える）
docker logs -f web           # ログを追いかける（Ctrl+C で抜ける）
```

## 4. 動いているコンテナの中でコマンドを実行

```bash
docker exec -it web sh
# 中で:
echo '<h1>Hello from container!</h1>' > /usr/share/nginx/html/index.html
exit
curl http://localhost:8080
```

## 5. 停止・再開・削除

```bash
docker stop web      # 停止
docker ps -a         # 停止中も含めて表示（STATUS が Exited）
docker start web     # 再開（さっき書き換えた index.html は残っている）
docker rm -f web     # 強制削除
```

> **ポイント**: コンテナを削除すると、中で書き換えた内容は消えます。
> 残したいデータは「ボリューム」に置きます → [04-volumes](../04-volumes/)

## 6. イメージの操作

```bash
docker images                  # ローカルのイメージ一覧
docker pull python:3.12-slim   # 取得だけする
docker image inspect nginx:1.27-alpine | head -40   # 詳細情報
docker rmi hello-world         # イメージ削除
```

## やってみよう

1. `nginx:1.27-alpine` をポート `8081` と `8082` で 2 つ同時に起動し、両方に curl してみよう
2. `docker stats` を実行し、コンテナの CPU / メモリ使用量を見てみよう
3. `docker run --rm alpine:3.20 echo hello` を実行して、`docker ps -a` に何も残らないことを確認しよう

<details>
<summary>解答例</summary>

```bash
docker run -d --name web1 -p 8081:80 nginx:1.27-alpine
docker run -d --name web2 -p 8082:80 nginx:1.27-alpine
curl -s localhost:8081 | head -4
curl -s localhost:8082 | head -4
docker stats --no-stream
docker rm -f web1 web2
```

同じイメージから独立したコンテナが 2 つ作れることがわかります。
</details>
