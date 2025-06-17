import ai_agent.config as config
import requests

def fetch_url(url):
    try:
        response = requests.get(url, timeout=config.DEFAULT_TIMEOUT, headers={"User-Agent": config.USER_AGENT})
        response.raise_for_status()
        return response
    except Exception as e:
        print(f"Fetch error: {e}")
        return None
