from flask import Flask, render_template, jsonify
import os
import requests

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/fetch', methods=['GET'])
def fetch_data():
    try:
        # Make a request to the SpaceX API via the ExternalName service
        response = requests.get(
            'http://spacex-api-service/v4/launches/latest',   #spacex-api-service (ExternalName's name)
            headers={'Host': os.getenv('SPACEX_API_HOST')}
        )
        response.raise_for_status()
        data = response.json()
        return jsonify({
            "mission_name": data.get("name"),
            "launch_date": data.get("date_utc"),
            "rocket_id": data.get("rocket"),
            "details": data.get("details", "No details available.")
        })
    except requests.exceptions.RequestException as e:
        return jsonify({"error": str(e)}), 500