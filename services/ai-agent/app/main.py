import ai_agent.config as config
import sys
from ai_agent.classifier import classify
from ai_agent.analyzer import analyze
from ai_agent.planner import plan
from ai_agent.executor import execute_plan
from ai_agent.url_fetcher import fetch_url
from ai_agent.utils import print_disclaimer

# moved to config

def run_agent(url: str):
    response = fetch_url(url)
    if not response:
        print("❌ Failed to fetch URL.")
        return

    classification = classify(response)
    intent = analyze(response)
    plan_name = plan(classification, intent)
    result = execute_plan(plan_name, response, url)

    print(f"\n🔍 Classification: {classification}")
    print(f"🧠 Intent: {intent}")
    print(f"🗺️ Plan: {plan_name}")
    print(f"📦 Result: {result}")
    print_disclaimer(url)

def agent_repl():
    print("🟢 AI Agent is live. Type a URL to analyze or 'exit' to quit.")
    urls_entered = 0
    while urls_entered < config.MAX_URLS:
        try:
            url = input("🌐 URL> ").strip()
            if url.lower() == "exit":
                break
            run_agent(url)
            urls_entered += 1
        except EOFError:
            break
    if urls_entered >= config.MAX_URLS:
        print(f"🔒 URL limit reached ({MAX_URLS}). Restart the agent to continue.")

if __name__ == "__main__":
    urls = sys.argv[1:]
    if urls:
        if len(urls) > config.MAX_URLS:
            print(f"❌ Too many URLs passed. Max allowed is {MAX_URLS}.")
            sys.exit(1)
        for url in urls:
            run_agent(url)
    else:
        agent_repl()
