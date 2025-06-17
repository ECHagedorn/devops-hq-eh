from bs4 import BeautifulSoup

def execute_plan(plan, response=None, url=None):
    if plan == "direct_parse":
        try:
            data = response.json()
            return f"Parsed JSON:\nTop-level keys: {list(data.keys())}"
        except Exception as e:
            return f"Failed to parse JSON: {str(e)}"

    if plan == "scrape_with_bs4":
        try:
            soup = BeautifulSoup(response.text, "html.parser")
            title = soup.title.string.strip() if soup.title else "No title"
            links = [a.get('href') for a in soup.find_all('a', href=True)]
            return f"HTML Title: {title}\nFound {len(links)} links"
        except Exception as e:
            return f"Failed to scrape HTML: {str(e)}"

    if plan == "manual_api_discovery":
        return "This appears to be a JavaScript-rendered site. Consider using a headless browser to inspect dynamic API activity."

    if plan in ["crawl_er_api", "crawl_coc_api"]:
        if "comelec.gov.ph" not in (url or ""):
            return "This action is COMELEC-specific and not applicable to this domain."
        return "Would crawl COMELEC's public API endpoints starting at /api/regions"

    return "No execution performed"
