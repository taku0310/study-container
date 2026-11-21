# ベースイメージ: Python 3.12 の軽量版
FROM python:3.12-slim

# 以降のコマンドを実行するディレクトリ
WORKDIR /app

# 依存関係ファイルだけ先にコピー → pip install
# (ソースを変更しても、requirements.txt が変わらなければこの層はキャッシュされる)
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# アプリ本体をコピー
COPY app/ .

# ドキュメント目的: このコンテナは 5000 番ポートで待ち受ける
EXPOSE 5000

# コンテナ起動時に実行するコマンド
CMD ["python", "app.py"]
