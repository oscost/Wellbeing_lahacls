# app.py
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Dict, Any, Optional
import asyncio
import uvicorn
from datetime import datetime, timedelta
import json

# Import the simplified Fetch.ai agent system
from fetch_agents import FetchAgentSystem

app = FastAPI(title="Wellbeing Fetch.ai Backend")

# Add CORS middleware to allow requests from your iOS app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Update this for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize the Fetch.ai agent system
agent_system = FetchAgentSystem()

# Define data models
class WellbeingEntry(BaseModel):
    date: str
    mood: int
    energy: int
    steps: int
    screenTimeMinutes: int
    sleepHours: float
    heartRate: int
    caloriesBurned: int
    waterIntake: int
    dailyJournal: str
    emotionalState: str

class AnalysisRequest(BaseModel):
    entries: List[WellbeingEntry]

class Stressor(BaseModel):
    name: str
    level: int
    description: str
    impact: str
    recommendations: Optional[List[str]] = None

class Recommendation(BaseModel):
    target: str
    recommendation: str
    priority: str
    actions: List[str]

class AnalysisResponse(BaseModel):
    session_id: str
    analysis_timestamp: str
    stressors: List[Dict[str, Any]]
    recommendations: List[Dict[str, Any]]
    insights: Dict[str, Any]

@app.get("/")
async def root():
    """Health check endpoint"""
    return {"status": "online", "service": "Wellbeing Fetch.ai Backend"}

@app.post("/analyze", response_model=AnalysisResponse)
async def analyze_wellbeing_data(request: AnalysisRequest):
    """Analyze wellbeing data using Fetch.ai agents"""
    try:
        # Convert Pydantic models to dictionaries
        entries = [entry.dict() for entry in request.entries]
        
        # Process data with our Fetch.ai agent system
        result = await agent_system.analyze_data(entries)
        
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Analysis failed: {str(e)}")

@app.get("/sample")
async def get_sample_response():
    """Returns a sample analysis response for testing"""
    # Sample entries based on your app structure
    sample_entries = [
        {
            "date": (datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)).isoformat(),
            "mood": 6,
            "energy": 5,
            "steps": 7500,
            "screenTimeMinutes": 240,
            "sleepHours": 6.5,
            "heartRate": 72,
            "caloriesBurned": 1800,
            "waterIntake": 1500,
            "dailyJournal": "Had a busy day at work with multiple deadlines. Felt a bit stressed but managed to complete most tasks.",
            "emotionalState": "Tired but satisfied with progress. Worried about tomorrow's presentation."
        },
        {
            "date": (datetime.now().replace(hour=0, minute=0, second=0, microsecond=0) - 
                     timedelta(days=1)).isoformat(),
            "mood": 7,
            "energy": 6,
            "steps": 9000,
            "screenTimeMinutes": 180,
            "sleepHours": 7.2,
            "heartRate": 68,
            "caloriesBurned": 2100,
            "waterIntake": 2000,
            "dailyJournal": "Productive day with good team meeting. Went for a walk during lunch break which felt refreshing.",
            "emotionalState": "Generally positive, though slightly anxious about upcoming deadlines."
        },
        {
            "date": (datetime.now().replace(hour=0, minute=0, second=0, microsecond=0) - 
                     timedelta(days=2)).isoformat(),
            "mood": 4,
            "energy": 3,
            "steps": 3000,
            "screenTimeMinutes": 320,
            "sleepHours": 5.5,
            "heartRate": 75,
            "caloriesBurned": 1600,
            "waterIntake": 1200,
            "dailyJournal": "Difficult day with technology issues. Spent too much time troubleshooting and fell behind on work.",
            "emotionalState": "Frustrated and tired. Didn't sleep well last night which made everything harder."
        }
    ]
    
    # Process sample data
    result = await agent_system.analyze_data(sample_entries)
    
    return result

if __name__ == "__main__":
    uvicorn.run("app:app", host="0.0.0.0", port=8000, reload=True)