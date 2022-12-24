import os

from flask import Flask, Response

app = Flask(__name__)

@app.route("/")
def home():
    """Return a simple greeting message"""
    return "Self-healing demo app running\n"


@app.route("/health/live")
def live():
    """Liveness probe endpoint to check if the service is running"""
    return Response("OK\n", status=200)


@app.route("/health/ready")
def ready():
    """Readiness probe endpoint to check if the service is ready to serve requests"""
    return Response("READY\n", status=200)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
