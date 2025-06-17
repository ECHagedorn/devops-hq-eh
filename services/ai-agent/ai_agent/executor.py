def execute_plan(plan):
    if plan == "crawl_er_api":
        return "Would call /api/regions → ... → /api/er-summary"
    if plan == "crawl_coc_api":
        return "Would call /api/regions → ... → /api/coc-summary"
    if plan == "direct_parse":
        return "Would parse JSON"
    if plan == "scrape_with_bs4":
        return "Would scrape with BeautifulSoup"
    if plan == "manual_api_discovery":
        return "Needs JS or browser emulation to discover API"
    return "No execution performed"
