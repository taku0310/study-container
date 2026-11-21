import os
import socket

from flask import Flask

app = Flask(__name__)


@app.get("/")
def index():
    greeting = os.environ.get("GREETING", "Hello")
    return f"{greeting} from container! (hostname: {socket.gethostname()})\n"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
