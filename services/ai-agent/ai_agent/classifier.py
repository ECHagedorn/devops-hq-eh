def classify_page(response):
    content_type = response.headers.get("Content-Type", "").lower()
    body = response.text.lower()

    if "application/json" in content_type:
        return "json-api"
    elif "text/html" in content_type:
        if "react" in body or "<script" in body and "loading" in body:
            return "js-app"
        elif "<html" in body:
            return "static-html"
    return "unknown"
