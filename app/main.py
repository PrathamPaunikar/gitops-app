# app/main.py
from flask import Flask, jsonify
app = Flask(__name__)

#@app.route('/')
#def home():
#    return jsonify({"message": "Hello from GitOps!", "version": "3.0"

# app/main.py — change the home route to:
@app.route('/')
def home():
    raise Exception("Simulated crash for rollback test")

@app.route('/health')
def health():
    return jsonify({"status": "ok"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
