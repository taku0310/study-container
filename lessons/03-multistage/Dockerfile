# ---- ステージ1: ビルド用 ----
FROM golang:1.23 AS builder

WORKDIR /src
COPY go.mod ./
COPY *.go ./
# CGO を無効にして静的リンクのバイナリを作る（libc なしで動く）
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /app .

# ---- ステージ2: 実行用 ----
# scratch = 中身が空っぽの特別なイメージ
FROM scratch

# builder ステージからバイナリだけをコピー
COPY --from=builder /app /app

EXPOSE 8080
ENTRYPOINT ["/app"]
