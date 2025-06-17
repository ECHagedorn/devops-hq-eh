def plan_action(page_type, intent):
    if "election returns" in intent:
        return "crawl_er_api"
    elif "certificate of canvass" in intent:
        return "crawl_coc_api"
    elif page_type == "json-api":
        return "direct_parse"
    elif page_type == "static-html":
        return "scrape_with_bs4"
    elif page_type == "js-app":
        return "manual_api_discovery"
    return "no_action"
