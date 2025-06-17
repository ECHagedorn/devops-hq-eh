def agent_repl():
    print("🟢 AI Agent is live. Type a URL to analyze or 'exit' to quit.")
    urls = []

    while True:
        url = input("🌐 URL> ").strip()
        if url.lower() == "exit":
            break
        urls.append(url)

        if len(urls) > 10:
            print("❌ Limit reached: Only 10 URLs allowed per batch.")
            break

    for url in urls:
        handle_url(url)
import sys
from ai_agent.url_fetcher import fetch_url
from ai_agent.classifier import classify
from ai_agent.analyzer import analyze
from ai_agent.planner import plan
from ai_agent.executor import execute_plan
from ai_agent.utils import print_disclaimer

def handle_url(url):
    response = fetch_url(url)
    if not response:
        print("❌ Failed to fetch URL.")
        return
    classification = classify(response)
    intent = analyze(response)
    next_step = plan(classification, intent)
    result = execute_plan(next_step, response=response, url=url)

    print(f"\n🔍 Classification: {classification}")
    print(f"🧠 Intent: {intent}")
    print(f"🗺️ Plan: {next_step}")
    print(f"📦 Result: {result}")

    print_disclaimer(url)

def agent_repl():
