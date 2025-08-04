"""
AI-NOC Dashboard Backend - Simple Working Version
"""
import asyncio
import logging
import json
from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(title="AI-NOC Dashboard API", version="1.0.0")

# Add CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_startup
async def startup_event():
    logger.info("🖥️ AI-NOC Dashboard Backend Started")

@app.get("/")
async def root():
    return {"message": "AI-NOC Dashboard API is running"}

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "dashboard-backend",
        "version": "1.0.0"
    }

@app.get("/api/devices")
async def get_devices():
    return {
        "devices": [
            {
                "id": "device_1",
                "name": "Core Router",
                "ip": "192.168.1.1",
                "type": "router",
                "status": "up",
                "cpu_usage": 23.5,
                "memory_usage": 67.2
            },
            {
                "id": "device_2",
                "name": "Access Switch",
                "ip": "192.168.1.10",
                "type": "switch",
                "status": "up",
                "cpu_usage": 12.8,
                "memory_usage": 45.1
            }
        ]
    }

@app.get("/api/metrics")
async def get_metrics():
    return {
        "network_throughput": 856.7,
        "packet_loss": 0.02,
        "latency": 15.6,
        "availability": 99.97
    }

@app.get("/api/alerts")
async def get_alerts():
    return {
        "alerts": [
            {
                "id": "alert_1",
                "title": "High CPU Usage",
                "severity": "warning",
                "device": "192.168.1.1",
                "timestamp": "2 minutes ago"
            }
        ]
    }

# Proxy AI endpoints
@app.get("/api/ai/insights")
async def get_ai_insights():
    # In production, this would call the AI engine
    return [
        {
            "id": "insight_1",
            "title": "Network Status Good",
            "description": "All systems operating normally",
            "confidence": 95.0
        }
    ]

@app.websocket("/ws/realtime")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    try:
        while True:
            data = {
                "timestamp": "2024-01-01T00:00:00Z",
                "throughput": 856.7,
                "latency": 15.6
            }
            await websocket.send_text(json.dumps(data))
            await asyncio.sleep(5)
    except:
        pass

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
