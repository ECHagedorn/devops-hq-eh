from ai_agent.url_fetcher import fetch_url
from ai_agent.classifier import classify_page
from ai_agent.analyzer import analyze_page
from ai_agent.planner import plan_action
from ai_agent.executor import execute_plan
from ai_agent.utils import print_disclaimer
import sys

def main(url):
    response = fetch_url(url)
    if not response:
        print("❌ Failed to fetch URL.")
        return

    page_type = classify_page(response)
    intent = analyze_page(url, response)
    plan = plan_action(page_type, intent)
    result = execute_plan(plan)

    print("\n🔍 Classification:", page_type)
    print("🧠 Intent:", intent)
    print("🗺️ Plan:", plan)
    print("�� Result:", result)

    print_disclaimer()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python main.py <url>")
        sys.exit(1)
    main(sys.argv[1])
