import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from app.main import app

def test_home():
    client = app.test_client()
    r = client.get('/')
    assert r.status_code == 200

def test_health():
    client = app.test_client()
    r = client.get('/health')
    assert r.status_code == 200
