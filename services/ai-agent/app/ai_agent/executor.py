import ai_agent.config as config
def execute_plan(plan, response=None, url=None):
    if isinstance(response, list) and len(response) > 50:
        return "❌ Too many responses passed in. Max 50 allowed."

    if plan == config.PLAN_CRAWL_ER_API:
        return "Would call /api/regions → ... → /api/er-summary"
    if plan == config.PLAN_CRAWL_COC_API:
        return "Would call /api/regions → ... → /api/coc-summary"
    if plan == config.PLAN_DIRECT_PARSE:
        return "Would parse JSON"
    if plan == config.PLAN_SCRAPE_BS4:
        return "Would scrape with BeautifulSoup"
    if plan == config.PLAN_MANUAL_DISCOVERY:
        return "Needs JS or browser emulation to discover API"
    return "No execution performed"
