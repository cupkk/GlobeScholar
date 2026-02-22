import os
import json
import uuid
import datetime
from pydantic import BaseModel, Field
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()

# We define the strict Output Schema we expect from the LLM,
# which perfectly matches the iOS SwiftData OpportunityItem model.
class OpportunitySchema(BaseModel):
    schoolAbbr: str = Field(description="Abbreviation of the school, e.g., MIT, STFD, CMU. Max 4 chars uppercase.")
    schoolName: str = Field(description="Full name of the university.")
    programName: str = Field(description="Name of the specific program or lab opening.")
    location: str = Field(description="City and Country where the program takes place.")
    description: str = Field(description="A concise 1-2 sentence overview of the program.")
    websiteUrl: str = Field(description="The official URL to apply or learn more.")
    tags: list[str] = Field(description="Array of 2-3 short tags, e.g., ['Summer Research', 'CS']")
    deadline_iso: str = Field(description="The application deadline in strict ISO8601 format (e.g., '2027-02-15T23:59:59Z'). If no exact time, assume 23:59:59Z. If no exact year, infer from context or use next year.")

def parse_unstructured_text(raw_text: str) -> dict | None:
    """
    Takes raw, unstructured text (from a scraped website, tweet, or forum post)
    and uses an LLM to extract and standardize it into our strict JSON format.
    """
    
    api_key = os.getenv("DEEPSEEK_API_KEY")
    if not api_key:
        print("⚠️ DEEPSEEK_API_KEY not found in environment. Skipping LLM extraction.")
        return None
        
    client = OpenAI(
        api_key=api_key,
        base_url="https://api.deepseek.com/v1" # or the specific base URL Deepseek provides
    )
    
    system_prompt = """
    You are an expert data extraction assistant for a university application tracking app.
    Your job is to read unstructured text regarding academic opportunities (like Summer Research, PhD openings)
    and extract the core entities into the provided strict JSON schema.
    If a deadline is mentioned vaguely (e.g., "mid-April"), make your best estimate in ISO8601 format.
    """
    
    try:
        # DeepSeek provides compatible completion endpoints, but they may not fully support structured outputs via `.parse()` yet, 
        # so you might need to use standard JSON mode depending on the DeepSeek model version (e.g., deepseek-chat).
        # We will keep the structured output format here as DeepSeek moves toward OpenAI API compatibility.
        completion = client.chat.completions.create(
            model="deepseek-chat",
            messages=[
                {"role": "system", "content": system_prompt + "\nPlease output ONLY valid JSON matching the schema."},
                {"role": "user", "content": f"Extract the opportunity data from this text:\n\n{raw_text}"}
            ],
            response_format={"type": "json_object"},
            temperature=0.1
        )
        
        # DeepSeek currently requires manual parsing of the JSON string
        raw_json_str = completion.choices[0].message.content
        parsed_dict = json.loads(raw_json_str)
        
        # Validate against our Pydantic schema
        validated_data = OpportunitySchema(**parsed_dict)
        
        # Convert Pydantic model back to a dictionary and append our UUID
        opportunity_dict = validated_data.model_dump()
        opportunity_dict["id"] = str(uuid.uuid4())
        
        # Map the 'deadline_iso' key back to exactly 'deadline' for the iOS App
        opportunity_dict["deadline"] = opportunity_dict.pop("deadline_iso")
        
        return opportunity_dict
        
    except Exception as e:
        print(f"❌ Error during LLM extraction: {e}")
        return None

# --- Example Usage for Testing ---
if __name__ == "__main__":
    sample_raw_post = """
    🚨 NEW OPPORTUNITY 🚨
    The Human-Computer Interaction Lab at the University of Washington (UW) is looking for 2 undergrads 
    for an amazing 10-week summer research sprint focusing on AR/VR accessibility! ✨
    You'll be stationed in Seattle, WA. No prior AR experience required, but strong CS fundamentals help.
    Apps close definitively on March 15th at Midnight. 
    Drop your app here: https://hcil.cs.washington.edu/apply-summer
    """
    
    print("Sending raw text to LLM for extraction...")
    result = parse_unstructured_text(sample_raw_post)
    
    if result:
        print("\n✅ Successfully standardized into Native iOS Schema:")
        print(json.dumps(result, indent=2))
