import json
import uuid
import random
from datetime import datetime, timedelta

def generate_mock_scraped_data():
    """
    In a real-world scenario, you would use requests + BeautifulSoup 
    to scrape specific university pages or aggregation sites like NSF REU,
    or use APIs like Twitter/X to find #SummerResearch hashtags.
    
    For MVP demonstration, this acts as the "Cleaning & Standardization" layer
    that format raw text into the strict iOS OpportunityItem JSON structure.
    """
    
    # Mock source data extracted from hypothetical HTML
    raw_opportunities = [
        {
            "schoolAbbr": "MIT",
            "schoolName": "Massachusetts Institute of Technology",
            "programName": "MSRP - MIT Summer Research Program",
            "location": "Cambridge, MA, USA",
            "description": "The MIT Summer Research Program (MSRP) seeks to promote the value of graduate education, to improve the research enterprise...",
            "websiteUrl": "https://odge.mit.edu/undergraduate/msrp/",
            "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/MIT_logo.svg/512px-MIT_logo.svg.png",
            "tags": ["Summer Research", "Engineering", "Sciences"],
            "deadline_offset_days": 15
        },
        {
            "schoolAbbr": "STFD",
            "schoolName": "Stanford University",
            "programName": "SURF - Summer Undergraduate Research Fellowship",
            "location": "Stanford, CA, USA",
            "description": "SURF is a fully funded, eight-week summer residential program that brings 30 talented and motivated undergraduates...",
            "websiteUrl": "https://engineering.stanford.edu/students/programs/summer-undergraduate-research-fellowship-surf",
            "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/4/4b/Stanford_Cardinal_logo.svg",
            "tags": ["Summer Research", "Engineering"],
            "deadline_offset_days": 10
        },
        {
            "schoolAbbr": "CMU",
            "schoolName": "Carnegie Mellon University",
            "programName": "Robotics Institute Summer Scholars (RISS)",
            "location": "Pittsburgh, PA, USA",
            "description": "RISS is an intensive eleven-week summer undergraduate research program that immerses diverse cohorts of students...",
            "websiteUrl": "https://riss.ri.cmu.edu/",
            "imageUrl": "https://upload.wikimedia.org/wikipedia/en/thumb/b/bb/Carnegie_Mellon_University_seal.svg/512px-Carnegie_Mellon_University_seal.svg.png",
            "tags": ["Summer Research", "Robotics", "AI"],
            "deadline_offset_days": 25
        },
        {
            "schoolAbbr": "ETHZ",
            "schoolName": "ETH Zurich",
            "programName": "Student Summer Research Fellowship",
            "location": "Zurich, Switzerland",
            "description": "The Computer Science Department at ETH offers a new and exciting program that allows undergraduate and graduate students to obtain research experience...",
            "websiteUrl": "https://inf.ethz.ch/studies/summer-research-fellowship.html",
            "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/9/90/ETH_Zurich_Logo_black.svg",
            "tags": ["Summer Research", "CS", "Europe"],
            "deadline_offset_days": 45
        },
        {
            "schoolAbbr": "EPFL",
            "schoolName": "EPFL",
            "programName": "Summer in the Lab",
            "location": "Lausanne, Switzerland",
            "description": "A 2 to 3-month paid summer internship for bachelor and master students in one of the School of Computer and Communication Sciences (IC).",
            "websiteUrl": "https://www.epfl.ch/schools/ic/education/summer-in-the-lab/",
            "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/EPFL_Logo.svg/512px-EPFL_Logo.svg.png",
            "tags": ["Summer Research", "CS", "Europe"],
            "deadline_offset_days": 30
        },
        {
            "schoolAbbr": "UCB",
            "schoolName": "UC Berkeley",
            "programName": "Amgen Scholars Program",
            "location": "Berkeley, CA, USA",
            "description": "An undergraduate summer research program in science and biotechnology.",
            "websiteUrl": "https://amgenscholars.berkeley.edu/",
            "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a1/Seal_of_University_of_California%2C_Berkeley.svg/512px-Seal_of_University_of_California%2C_Berkeley.svg.png",
            "tags": ["Summer Research", "Biology", "Biotech"],
            "deadline_offset_days": 5
        }
    ]

    # --- ADVANCED AI PIPELINE PATH ---
    # Here we simulate fetching unstructured data from elsewhere (like a forum post)
    # and feeding it into our OpenAI cleaner to enforce standard JSON.
    from cleaner import parse_unstructured_text # type: ignore
    import time
    
    sample_raw_post = """
    🚨 NEW OPPORTUNITY 🚨
    The Human-Computer Interaction Lab at the University of Washington (UW) is looking for 2 undergrads 
    for an amazing 10-week summer research sprint focusing on AR/VR accessibility! ✨
    You'll be stationed in Seattle, WA. No prior AR experience required, but strong CS fundamentals help.
    Apps close definitively on March 15th next year at Midnight. 
    Drop your app here: https://hcil.cs.washington.edu/apply-summer
    """
    
    # Try using the AI pipeline if an API key is present
    print("🤖 Attempting to run AI extraction for an unstructured Reddit post...")
    ai_item = parse_unstructured_text(sample_raw_post)

    formatted_items = []
    
    # Process the legacy hardcoded ones
    for item in raw_opportunities:
        # Calculate dynamic deadline based on current execution time
        # Explicitly cast to float to satisfy static type checkers that infer dict values as Unions
        offset_days: float = float(str(item.get('deadline_offset_days', 0)))
        deadline_date = datetime.now() + timedelta(days=offset_days)
        
        # Build the exact JSON schema that the iOS SwiftData model expects
        formatted_item = {
            "id": str(uuid.uuid4()), # Unique UUID string mimicking Swift's UUID
            "schoolAbbr": item["schoolAbbr"],
            "schoolName": item["schoolName"],
            "programName": item["programName"],
            "location": item["location"],
            "description": item["description"],
            "websiteUrl": item["websiteUrl"],
            "imageUrl": item.get("imageUrl", ""),
            "deadline": deadline_date.isoformat(), # ISO8601 string for Swift's JSONDecoder
            "tags": item["tags"]
        }
        
        formatted_items.append(formatted_item)
        
    # Append the AI generated item if successful
    if ai_item:
        print("✅ OpenAI successfully parsed and standardized the Reddit post! Appending to DB.")
        formatted_items.append(ai_item)
        
    return formatted_items

def main():
    print("🚀 Starting Data Scraping & Aggregation Engine...")
    
    # 1. Scrape and clean data
    scraped_data = generate_mock_scraped_data()
    print(f"✅ Successfully scraped and cleaned {len(scraped_data)} opportunities.")
    
    # 2. Save to JSON file
    output_filename = "opportunities.json"
    with open(output_filename, 'w', encoding='utf-8') as f:
        json.dump(scraped_data, f, ensure_ascii=False, indent=2)
        
    print(f"💾 Data saved to {output_filename}. Ready for remote hosting!")
    
if __name__ == "__main__":
    main()
