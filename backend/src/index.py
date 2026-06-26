import os
# pyrefly: ignore [missing-import]
import uvicorn
# pyrefly: ignore [missing-import]
from fastapi import FastAPI, Body
# pyrefly: ignore [missing-import]
from fastapi.responses import PlainTextResponse
# pyrefly: ignore [missing-import]
from geopy.geocoders import Nominatim
from collections import Counter

app = FastAPI()
# Adding a custom user_agent prevents OpenStreetMap from blocking your requests
geolocator = Nominatim(user_agent="civil_voice_of_people_app")

@app.get("/", response_class=PlainTextResponse)
def home():
    return "Civil App Backend is running! 🚀"

@app.post("/api/heatmap")
def generate_heatmap(payload: dict = Body(...)):
    """
    Expects payload: 
    {"locations": ["Modern candles, Marie Oulgaret, Puducherry, Puducherry, 605110", ...]}
    """
    raw_locations = payload.get("locations", [])
    cleaned_search_queries = []

    # 1. Clean the strings so the geocoding engine doesn't get confused by shop names
    for loc in raw_locations:
        parts = [p.strip() for p in loc.split(",") if p.strip()]
        
        # If the string has multiple parts, grab the last 2 or 3 items 
        # (e.g., "Puducherry, Puducherry, 605110")
        if len(parts) >= 3:
            query = ", ".join(parts[-3:])
        else:
            query = ", ".join(parts)
            
        cleaned_search_queries.append(query)

    # 2. Count frequencies of the locations to get our heatmap intensity weight
    location_counts = Counter(cleaned_search_queries)
    
    heatmap_data = []
    
    # 3. Request Coordinates
    for query, weight in location_counts.items():
        try:
            # Look up the cleaned address string
            location = geolocator.geocode(query, timeout=10)
            if location:
                heatmap_data.append({
                    "address": query,
                    "lat": location.latitude,
                    "lng": location.longitude,
                    "weight": weight
                })
        except Exception as e:
            print(f"Skipping geocode for query '{query}' due to error: {e}")
            continue

    return heatmap_data

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 3000))
    print(f"Server running on port {port}")
    uvicorn.run(app, host="0.0.0.0", port=port)