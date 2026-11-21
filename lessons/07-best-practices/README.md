# 07. ベストプラクティス

動けば OK から一歩進んで、**安全で運用しやすい** イメージを作ります。
[Dockerfile](Dockerfile) にはコメント番号付きでポイントを書いています。

## チェックリスト

| # | ポイント | 理由 |
|---|----------|------|
| 1 | ベースイメージのタグを固定 | `latest` は勝手に変わり、ある日突然壊れる |
| 2 | 軽量なベースを選ぶ（`-slim`, `alpine`, distroless） | サイズ削減・脆弱性減 |
| 3 | 変更頻度の低い命令を上に | ビルドキャッシュが効く |
| 4〜6 | **root で動かさない**（`USER`） | コンテナ脱出時の被害を抑える |
| 7 | `HEALTHCHECK` を書く | 「プロセスは生きているが応答しない」を検知できる |
| 8 | `CMD` は exec 形式 `["..."]` | シグナル（停止要求）がアプリに正しく届く |
| - | 秘密情報をイメージに入れない | `docker history` で誰でも見られる。実行時に環境変数や secrets で渡す |
| - | 1 コンテナ 1 プロセス（1 つの役割） | スケール・再起動・ログ管理が楽 |

## 1. ビルドと実行

```bash
cd lessons/07-best-practices
docker build -t bestapp .
docker run -d --name best -p 8000:8000 bestapp
curl localhost:8000
# => running as user: appuser (uid=10001), env=production
```

## 2. ヘルスチェックを見る

```bash
docker ps   # STATUS が (health: starting) → (healthy) に変わる
docker inspect --format '{{json .State.Health}}' best
```

## 3. root でないことを確かめる

```bash
docker exec best whoami          # => appuser
docker exec best touch /etc/x    # => Permission denied
```

## 4. 実行時の設定上書き

```bash
docker rm -f best
docker run -d --name best -p 8000:8000 -e APP_ENV=staging bestapp
curl localhost:8000   # env=staging
```

## 5. さらに堅くする（実行時オプション）

```bash
docker rm -f best
docker run -d --name best -p 8000:8000 \
  --read-only --tmpfs /tmp \
  --cap-drop ALL \
  --memory 256m --cpus 0.5 \
  bestapp
curl localhost:8000
docker rm -f best
```

- `--read-only` ルートファイルシステムを読み取り専用に
- `--cap-drop ALL` Linux ケーパビリティ（特権）をすべて外す
- `--memory` / `--cpus` リソース制限

## やってみよう

1. `USER appuser` の行を消してビルドし、`whoami` の結果を比べよう
2. `docker history bestapp` を見て、`ENV` で秘密情報を入れると何が問題か考えよう
3. （発展）[Trivy](https://github.com/aquasecurity/trivy) で脆弱性スキャン:
   `docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image bestapp`

<details>
<summary>解答例</summary>

1. `root` と表示されます。アプリに脆弱性があった場合、コンテナ内で何でもできてしまいます。
2. `ENV` や `RUN echo $SECRET` の内容は `docker history` やイメージのレイヤーに残り、イメージを入手した人なら誰でも読めます。
   ビルド時に必要な秘密は `RUN --mount=type=secret,...`、実行時の秘密は環境変数や Docker/Kubernetes の secrets で渡します。
</details>

---

🎉 お疲れさまでした！次のステップとしては **Kubernetes**（kind / minikube）や、GitHub Actions でのイメージ自動ビルドがおすすめです。
