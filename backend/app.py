from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route('/api/items', methods=['GET'])
def get_items():
    return jsonify([
        {'id': 1, 'name': 'Item 1'},
        {'id': 2, 'name': 'Item 2'}
    ])


@app.route('/api/items', methods=['POST'])
def create_item():
    return jsonify({'message': 'Created'})

if __name__ == '__main__':
    app.run(debug=True, port=5000)
