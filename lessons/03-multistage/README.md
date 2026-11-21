# 03. マルチステージビルド

コンパイルが必要な言語では、**ビルドに必要なもの**（コンパイラ等）と **実行に必要なもの**（バイナリだけ）が違います。
マルチステージビルドを使うと、最終イメージには実行に必要なものだけを入れられます。

```
[builder: golang:1.23 (~800MB)]  ──go build──▶  /app
                                                 │ COPY --from=builder
[runtime: scratch (0MB)]  ◀──────────────────────┘
```

## 1. 比べてみる

```bash
cd lessons/03-multistage
docker build -f Dockerfile.single -t tinyapp:single .
docker build -t tinyapp:multi .
docker images tinyapp
```

結果の例:

```
REPOSITORY   TAG      SIZE
tinyapp      multi    数 MB（5〜10MB 程度）
tinyapp      single   1GB 前後
```

（表示される値は Docker のバージョンや設定で多少変わります）

**100 倍以上** 違います。サイズが小さいと、pull が速くなり、攻撃対象（入っているソフト）も減ります。

## 2. 動かす

```bash
docker run -d --name tiny -p 8080:8080 tinyapp:multi
curl localhost:8080
```

## 3. scratch イメージの中を覗こうとすると…

```bash
docker exec -it tiny sh
# => exec: "sh": executable file not found
```

シェルすら入っていません。これが「最小」ということです。

```bash
docker rm -f tiny
```

## 4. `.dockerignore`

`docker build .` の `.` は **ビルドコンテキスト**（Docker デーモンに送られるファイル群）です。
`.dockerignore` に書いたファイルは送られないので、ビルドが速くなり、秘密情報の混入も防げます。

## やってみよう

1. 最終ステージを `FROM scratch` から `FROM alpine:3.20` に変えてビルドし、サイズと `docker exec ... sh` の挙動を比べよう
2. `docker build --target builder -t tinyapp:builder .` で途中のステージだけビルドしてみよう

<details>
<summary>解答例</summary>

1. alpine にすると ~13MB 程度になり、`sh` が使えるのでデバッグしやすくなります。サイズとデバッグのしやすさはトレードオフです。
   （distroless の `gcr.io/distroless/static` も定番の選択肢です）
2. `--target` を指定すると、そのステージまででビルドが止まります。テスト用ステージを作るときなどに使います。
</details>
