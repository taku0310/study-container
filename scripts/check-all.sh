#!/usr/bin/env bash
# 全レッスンのイメージがビルドでき、期待どおり動くかを確認するスクリプト
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/lessons"

pass() { printf '\033[32m✔ %s\033[0m\n' "$1"; }
fail() { printf '\033[31m✘ %s\033[0m\n' "$1"; exit 1; }

cleanup() {
  docker rm -f chk-02 chk-03 chk-05-api chk-07 >/dev/null 2>&1 || true
  docker network rm chk-net >/dev/null 2>&1 || true
  docker volume rm chk-vol >/dev/null 2>&1 || true
  (cd 06-compose && docker compose -p chk06 down -v >/dev/null 2>&1) || true
}
trap cleanup EXIT

# retry <回数> <コマンド...>: サーバーの起動待ち
retry() { local n=$1; shift; for _ in $(seq "$n"); do "$@" && return 0; sleep 1; done; return 1; }

echo "== 01 basics"
docker run --rm alpine:3.20 sh -c 'grep -q Alpine /etc/os-release' && pass "alpine コンテナが起動"

echo "== 02 dockerfile"
docker build -q -t study/myapp 02-dockerfile >/dev/null
docker run -d --name chk-02 -p 15000:5000 -e GREETING=Hi study/myapp >/dev/null
retry 15 sh -c 'curl -sf localhost:15000 | grep -q "Hi from container"' && pass "Flask アプリが応答" || fail "02"

echo "== 03 multistage"
docker build -q -t study/tiny 03-multistage >/dev/null
size=$(docker image inspect study/tiny --format '{{.Size}}')
[ "$size" -lt 20000000 ] && pass "マルチステージイメージは $((size / 1024 / 1024))MB" || fail "03 size=$size"
docker run -d --name chk-03 -p 18080:8080 study/tiny >/dev/null
retry 10 sh -c 'curl -sf localhost:18080 | grep -q tiny' && pass "scratch イメージが応答" || fail "03"

echo "== 04 volumes"
docker run --rm -v chk-vol:/data alpine:3.20 sh -c 'echo memo > /data/m.txt'
[ "$(docker run --rm -v chk-vol:/data alpine:3.20 cat /data/m.txt)" = memo ] && pass "ボリュームでデータが残る" || fail "04"

echo "== 05 networking"
docker network create chk-net >/dev/null
docker run -d --name chk-05-api --network chk-net nginx:1.27-alpine >/dev/null
retry 10 docker run --rm --network chk-net alpine:3.20 wget -qO- http://chk-05-api >/dev/null && pass "コンテナ名で名前解決" || fail "05"

echo "== 06 compose"
(cd 06-compose && docker compose -p chk06 up -d --build --quiet-pull >/dev/null 2>&1)
retry 20 sh -c 'curl -sf localhost:5000 >/dev/null' || fail "06 起動せず"
out=$(curl -sf localhost:5000)
echo "$out" | grep -q "2 回" && pass "カウンタが増加: $out" || fail "06: $out"

echo "== 07 best practices"
docker build -q -t study/best 07-best-practices >/dev/null
docker run -d --name chk-07 -p 18000:8000 study/best >/dev/null
retry 15 sh -c 'curl -sf localhost:18000 | grep -q "user: appuser"' && pass "非 root で実行" || fail "07"
retry 30 sh -c '[ "$(docker inspect -f {{.State.Health.Status}} chk-07)" = healthy ]' && pass "HEALTHCHECK が healthy" || fail "07 health"

echo
pass "全レッスン OK"
