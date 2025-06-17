import os
import sys
from ai_agent.url_fetcher import fetch_url
from ai_agent.classifier import classify_page
from ai_agent.analyzer import analyze_page
from ai_agent.planner import plan_action
from ai_agent.executor import execute_plan
from ai_agent.utils import print_disclaimer

def agent_repl():
    print("🟢 AI Agent is live. Type a URL to analyze or 'exit' to quit.")
    while True:
        url = input("🌐 URL> ").strip()
        if url.lower() == "exit":
            print("👋 Exiting.")
            break
        if not url.startswith("http"):
            print("❌ Invalid URL. Try again.")
            continue

        response = fetch_url(url)
        if not response:
            print("❌ Failed to fetch URL.")
            continue

        page_type = classify_page(response)
        intent = analyze_page(url, response)
        plan = plan_action(page_type, intent)
        result = execute_plan(plan)

        print("\n🔍 Classification:", page_type)
        print("🧠 Intent:", intent)
        print("🗺️ Plan:", plan)
        print("📦 Result:", result)
        print_disclaimer()

if __name__ == "__main__":
    agent_repl()
