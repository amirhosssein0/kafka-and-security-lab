from flask import Flask, jsonify
import random

app = Flask(__name__)

@app.route("/generate", methods=["GET"])
def generate():
    number = random.randint(0, 100)
    return jsonify(message=f"random number:{number}")