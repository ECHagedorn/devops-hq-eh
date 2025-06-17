from setuptools import setup, find_packages

setup(
    name="ai-agent",
    version="0.1.0",
    packages=find_packages(where="app"),
    package_dir={"": "app"},
    install_requires=[
        "requests",
        "beautifulsoup4"
    ],
    entry_points={
        "console_scripts": [
            "ai-agent = main:main"
        ]
    }
)
