# 02. Dockerfile を書く

自作アプリをイメージにします。このディレクトリには Flask の小さな Web アプリと `Dockerfile` が入っています。

```
02-dockerfile/
├── Dockerfile
└── app/
    ├── app.py
    └── requirements.txt
```

## 1. Dockerfile の主な命令

| 命令 | 役割 |
|------|------|
| `FROM` | ベースにするイメージ |
| `WORKDIR` | 作業ディレクトリ |
| `COPY` | ホストのファイルをイメージにコピー |
| `RUN` | ビルド時にコマンドを実行（パッケージのインストールなど） |
| `ENV` | 環境変数 |
| `EXPOSE` | 待ち受けポート（ドキュメント用。実際の公開は `-p`） |
| `CMD` | コンテナ起動時のデフォルトコマンド |

まず [Dockerfile](Dockerfile) を読んでみましょう。

## 2. ビルドと実行

```bash
cd lessons/02-dockerfile
docker build -t myapp:v1 .
docker run -d --name myapp -p 5000:5000 myapp:v1
curl http://localhost:5000
# => Hello from container! (hostname: xxxxxxxx)
```

環境変数を渡してみます:

```bash
docker rm -f myapp
docker run -d --name myapp -p 5000:5000 -e GREETING=こんにちは myapp:v1
curl http://localhost:5000
docker rm -f myapp
```

## 3. レイヤーとキャッシュ

Dockerfile の各命令は **レイヤー** になります。

```bash
docker history myapp:v1
```

`app.py` を少し書き換えてから再ビルドしてみましょう:

```bash
sed -i 's/from container/from container v2/' app/app.py
docker build -t myapp:v2 .
```

出力に `CACHED` と表示され、`pip install` の層が再利用されて一瞬で終わるはずです。
これは `requirements.txt` を **先に** コピーしているからです。

> **ポイント**: 変更が少ないもの（依存関係）を上に、よく変わるもの（ソースコード）を下に書く。

元に戻す: `git checkout app/app.py`

## やってみよう

1. Dockerfile の `COPY app/requirements.txt .` と `RUN pip install ...` を `COPY app/ .` の **後ろ** に移動し、`app.py` を変更して再ビルドしたらどうなるか確認しよう
2. `CMD` を上書きして、コンテナ内の Python のバージョンを表示しよう
3. 同じイメージから 3 つコンテナを起動し、hostname が違うことを確認しよう

<details>
<summary>解答例</summary>

1. `app.py` を変更するたびに `pip install` が毎回走るようになり、ビルドが遅くなります。

2. イメージ名の後ろにコマンドを書くと `CMD` を上書きできます:
   ```bash
   docker run --rm myapp:v1 python --version
   ```

3.
   ```bash
   for p in 5001 5002 5003; do docker run -d --name app$p -p $p:5000 myapp:v1; done
   for p in 5001 5002 5003; do curl -s localhost:$p; done
   docker rm -f app5001 app5002 app5003
   ```
</details>
