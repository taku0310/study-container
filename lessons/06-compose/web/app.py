import os

import redis
from flask import Flask

app = Flask(__name__)
# "redis" は compose.yaml のサービス名。Compose が作るネットワーク上で名前解決される
cache = redis.Redis(host=os.environ.get("REDIS_HOST", "redis"), port=6379)


@app.get("/")
def index():
    count = cache.incr("hits")
    return f"このページは {count} 回表示されました\n"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
