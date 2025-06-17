def print_disclaimer(url):
    if "comelec.gov.ph" not in url:
        return
    print("""
📜 DISCLAIMER:
This data was retrieved from the publicly accessible COMELEC 2025 election results portal:
→ https://2025electionresults.comelec.gov.ph

The information is provided as-is for educational, analytical, and civic transparency purposes.
It does not represent an official tally or endorsement by COMELEC or the Government of the Philippines.
Redistribution or publication of this data should clearly attribute COMELEC as the original source.
Please use responsibly and respect any official clarifications or updates from COMELEC.
""")
