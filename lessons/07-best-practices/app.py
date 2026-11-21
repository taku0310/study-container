import os
import pwd

from flask import Flask

app = Flask(__name__)


@app.get("/")
def index():
    user = pwd.getpwuid(os.getuid()).pw_name
    return f"running as user: {user} (uid={os.getuid()}), env={os.environ.get('APP_ENV')}\n"


@app.get("/health")
def health():
    return "ok\n"
