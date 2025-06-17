def print_disclaimer(url: str):
    if "comelec.gov.ph" in url:
        print("\n📜 DISCLAIMER:")
        print("This data was retrieved from the publicly accessible COMELEC 2025 election results portal:")
        print("→ https://2025electionresults.comelec.gov.ph")
        print("\nThe information is provided as-is for educational, analytical, and civic transparency purposes.")
        print("It does not represent an official tally or endorsement by COMELEC or the Government of the Philippines.")
        print("Redistribution or publication of this data should clearly attribute COMELEC as the original source.")
        print("Please use responsibly and respect any official clarifications or updates from COMELEC.\n")
