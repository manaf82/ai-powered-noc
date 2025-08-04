"""
AI-NOC Data Collector - Simple Working Version
"""
import asyncio
import logging
import os
from fastapi import FastAPI

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(title="AI-NOC Data Collector", version="1.0.0")

@app.on_startup
async def startup_event():
    logger.info("🚀 AI-NOC Data Collector Started")

@app.get("/")
async def root():
    return {"message": "AI-NOC Data Collector is running"}

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "data-collector",
        "version": "1.0.0"
    }

@app.get("/metrics")
async def get_metrics():
    return {
        "devices_monitored": 4,
        "metrics_collected": 1250,
        "status": "collecting"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
