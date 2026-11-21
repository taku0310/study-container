# (1) タグを固定する。latest は中身が変わるので再現性がない
FROM python:3.12-slim

# (2) Python 向けの定番設定
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_ENV=production

WORKDIR /app

# (3) 依存関係を先に入れてキャッシュを効かせる
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# (4) 専用の一般ユーザーを作る
RUN useradd --create-home --uid 10001 appuser

# (5) ファイルの所有者を appuser にしてコピー
COPY --chown=appuser:appuser app.py .

# (6) root ではなく一般ユーザーで実行
USER appuser

EXPOSE 8000

# (7) ヘルスチェック: Docker がアプリの生死を判定できる
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

# (8) 本番向け WSGI サーバーで起動。exec 形式（JSON 配列）で書く
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "2", "app:app"]
