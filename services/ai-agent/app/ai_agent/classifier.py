def classify(response):
    content_type = response.headers.get("Content-Type", "").lower()
    body = response.text.lower()

    if "application/json" in content_type:
        return "json-api"
    elif "text/plain" in content_type:
        return "plaintext"
    elif "text/html" in content_type:
        if "react" in body or "<script" in body and "loading" in body:
            return "js-app"
        return "static-html"
    elif "javascript" in content_type:
        return "js-app"
    return "unknown"

