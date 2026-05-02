from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route("/")
def index():
    return jsonify({
        "message": "prodstack is running",
        "version": "1.0.0"
    })

@app.route("/health")
def health():
    return jsonify({"status": "ok"})

@app.route("/info")
def info():
    return jsonify({
        "hostname": os.uname().nodename,
        "environment": os.getenv("ENV", "development")
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)