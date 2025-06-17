import requests

def fetch_url(url):
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        return response
    except Exception as e:
        print(f"Fetch error: {e}")
        return None
