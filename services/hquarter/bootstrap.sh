#!/bin/bash

# Create directories
mkdir -p app/static
mkdir -p app/templates

# Create requirements.txt
cat > requirements.txt <<EOF
flask==2.3.2
EOF

# Create app.py
cat > app/app.py <<EOF
from flask import Flask, render_template

app = Flask(__name__)

@app.route("/")
def home():
    return render_template("home.html", active="home")

@app.route("/about")
def about():
    return render_template("about.html", active="about")

@app.route("/services")
def services():
    return render_template("services.html", active="services")

@app.route("/projects")
def projects():
    return render_template("projects.html", active="projects")

@app.route("/contact")
def contact():
    return render_template("contact.html", active="contact")

if __name__ == "__main__":
    app.run(debug=True)
EOF

# Download a simple SVG gear icon for animation
cat > app/static/gear.svg <<EOF
<svg width="48" height="48" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
    <circle cx="24" cy="24" r="10" stroke="#00bfae" stroke-width="4" fill="none"/>
    <path d="M24 4v8M24 36v8M44 24h-8M12 24H4M36.97 11.03l-5.66 5.66M11.03 36.97l5.66-5.66M36.97 36.97l-5.66-5.66M11.03 11.03l5.66 5.66" stroke="#00bfae" stroke-width="3"/>
  </g>
</svg>
EOF

# Create base.html with gear animation and scroll click logic
cat > app/templates/base.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Emmanuel Hagedorn | Portfolio</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="icon" href="{{ url_for('static', filename='favicon.ico') }}">
    <style>
        html, body { background: #000; color: #fff; margin: 0; padding: 0; font-family: Arial, sans-serif; }
        .hamburger {
            position: fixed; top: 1.5em; right: 1.5em; width: 40px; height: 40px; z-index: 1001;
            background: none; border: none; cursor: pointer;
        }
        .hamburger span, .hamburger span:before, .hamburger span:after {
            display: block; background: #fff; height: 4px; width: 32px; border-radius: 2px; position: absolute; transition: 0.3s;
        }
        .hamburger span { position: relative; top: 18px; }
        .hamburger span:before { content: ''; position: absolute; top: -10px; left: 0; }
        .hamburger span:after { content: ''; position: absolute; top: 10px; left: 0; }
        nav {
            position: fixed; top: 0; right: 0; width: 220px; height: 100vh; background: #111;
            box-shadow: -2px 0 8px rgba(0,0,0,0.4); transform: translateX(100%);
            transition: transform 0.3s; z-index: 1000; display: flex; flex-direction: column; align-items: center; padding-top: 4em;
        }
        nav.open { transform: translateX(0); }
        nav a { color: #fff; text-decoration: none; margin: 1.2em 0; font-size: 1.2em; transition: color 0.2s; }
        nav a.active, nav a:hover { color: #00bfae; }
        section { padding: 4em 1em 3em 1em; max-width: 900px; margin: 0 auto; }
        @media (max-width: 600px) {
            section { padding: 4em 0.5em 2em 0.5em; }
            nav { width: 100vw; }
        }
        /* Spinning gear animation */
        .spinning-gear {
            position: fixed;
            bottom: 2em;
            right: 2em;
            width: 48px;
            height: 48px;
            z-index: 2000;
            animation: spin 2s linear infinite;
        }
        @keyframes spin {
            100% { transform: rotate(360deg);}
        }
    </style>
    <script>
        function toggleMenu() {
            document.getElementById('nav').classList.toggle('open');
        }
        function closeMenu() {
            document.getElementById('nav').classList.remove('open');
        }
        window.addEventListener('DOMContentLoaded', function() {
            document.querySelectorAll('nav a').forEach(function(link) {
                link.addEventListener('click', closeMenu);
            });

            // Scroll on click logic
            document.body.addEventListener('click', function(e) {
                // Ignore clicks on nav or hamburger
                if (e.target.closest('nav') || e.target.closest('.hamburger') || e.target.closest('.spinning-gear')) return;
                const y = e.clientY;
                const half = window.innerHeight / 2;
                if (y > half) {
                    window.scrollBy({top: window.innerHeight * 0.8, behavior: 'smooth'});
                } else {
                    window.scrollBy({top: -window.innerHeight * 0.8, behavior: 'smooth'});
                }
            });
        });
    </script>
</head>
<body>
    <button class="hamburger" onclick="toggleMenu()" aria-label="Open navigation">
        <span></span>
    </button>
    <nav id="nav">
        <a href="/" class="{% if active == 'home' %}active{% endif %}">HOME</a>
        <a href="/about" class="{% if active == 'about' %}active{% endif %}">ABOUT</a>
        <a href="/services" class="{% if active == 'services' %}active{% endif %}">SERVICES</a>
        <a href="/projects" class="{% if active == 'projects' %}active{% endif %}">PROJECTS</a>
        <a href="/contact" class="{% if active == 'contact' %}active{% endif %}">CONTACT</a>
    </nav>
    {% block content %}{% endblock %}
    <img src="{{ url_for('static', filename='gear.svg') }}" alt="Spinning Gear" class="spinning-gear">
</body>
</html>
EOF

# HOME
cat > app/templates/home.html <<EOF
{% extends "base.html" %}
{% block content %}
<section>
    <h1>Emmanuel Hagedorn</h1>
    <h2>DevOps Engineer & Automation Specialist</h2>
    <p>Welcome to my portfolio!</p>
</section>
{% endblock %}
EOF

# ABOUT
cat > app/templates/about.html <<EOF
{% extends "base.html" %}
{% block content %}
<section>
    <h2>About</h2>
    <p>
        I am Emmanuel Hagedorn, a DevOps Engineer & Automation Specialist.<br>
        I design, automate, and secure cloud infrastructure for modern teams.<br>
        From code to cloud, I deliver production-grade solutions with precision and reliability.
    </p>
</section>
{% endblock %}
EOF

# SERVICES
cat > app/templates/services.html <<EOF
{% extends "base.html" %}
{% block content %}
<section>
    <h2>Services</h2>
    <ul>
        <li>Cloud Infrastructure Automation (AWS, Azure, GCP)</li>
        <li>CI/CD Pipeline Design & Implementation</li>
        <li>Infrastructure as Code (Terraform, Ansible)</li>
        <li>Containerization & Orchestration (Docker, Kubernetes)</li>
        <li>Monitoring, Logging, and Security Automation</li>
    </ul>
</section>
{% endblock %}
EOF

# PROJECTS
cat > app/templates/projects.html <<EOF
{% extends "base.html" %}
{% block content %}
<section>
    <h2>Projects</h2>
    <ul>
        <li><strong>Automated Multi-Cloud Deployment:</strong> Designed and deployed scalable infrastructure across AWS and Azure using Terraform and Ansible.</li>
        <li><strong>CI/CD for Microservices:</strong> Built GitHub Actions pipelines for automated testing, building, and deployment of containerized microservices.</li>
        <li><strong>Kubernetes Monitoring Stack:</strong> Implemented Prometheus, Grafana, and Loki for observability in Kubernetes clusters.</li>
        <li><strong>Security Automation:</strong> Automated vulnerability scanning and compliance checks in CI/CD workflows.</li>
    </ul>
</section>
{% endblock %}
EOF

# CONTACT
cat > app/templates/contact.html <<EOF
{% extends "base.html" %}
{% block content %}
<section>
    <h2>Contact</h2>
    <p>
        Email: <a href="mailto:emmanuel.hagedorn@example.com">emmanuel.hagedorn@example.com</a><br>
        LinkedIn: <a href="https://ca.linkedin.com/in/echagedorn" target="_blank">echagedorn</a><br>
        GitHub: <a href="https://github.com/ECHagedorn" target="_blank">ECHagedorn</a>
    </p>
</section>
{% endblock %}
EOF

echo "Setup complete! To run your app:"
echo "1. python3 -m venv venv && source venv/bin/activate"
echo "2. pip install -r requirements.txt"
echo "3. cd app && flask run"
