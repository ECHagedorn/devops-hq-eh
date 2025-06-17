def analyze_page(url, response):
    url_lower = url.lower()
    text = response.text.lower()
    if "comelec" in url_lower and "er-result" in url_lower:
        return "election returns portal"
    if "coc-result" in url_lower:
        return "certificate of canvass portal"
    return "unknown site intent"
