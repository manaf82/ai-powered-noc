"""
AI Engine Service for Network Operations Center
Provides AI/ML capabilities for network monitoring
"""
import asyncio
import logging
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from anomaly_detector import NetworkAnomalyDetector
from traffic_predictor import TrafficPredictor
from root_cause_analyzer import RootCauseAnalyzer

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="AI-NOC AI Engine", version="1.0.0")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global AI components
anomaly_detector = NetworkAnomalyDetector()
traffic_predictor = TrafficPredictor()
rca_analyzer = RootCauseAnalyzer()

@app.on_startup
async def startup_event():
    """Initialize AI models on startup"""
    logger.info("Starting AI-NOC AI Engine Service")
    await anomaly_detector.initialize()
    await traffic_predictor.initialize()
    await rca_analyzer.initialize()

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "ai-engine",
        "models": {
            "anomaly_detector": anomaly_detector.is_loaded,
            "traffic_predictor": traffic_predictor.is_loaded,
            "rca_analyzer": rca_analyzer.is_loaded
        }
    }

@app.post("/api/ai/detect-anomalies")
async def detect_anomalies(data: dict):
    """Detect anomalies in network data"""
    try:
        anomalies = await anomaly_detector.detect(data)
        return {"anomalies": anomalies}
    except Exception as e:
        logger.error(f"Anomaly detection failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/ai/predict-traffic")
async def predict_traffic(data: dict):
    """Predict network traffic patterns"""
    try:
        predictions = await traffic_predictor.predict(data)
        return {"predictions": predictions}
    except Exception as e:
        logger.error(f"Traffic prediction failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/ai/analyze-root-cause")
async def analyze_root_cause(incident_data: dict):
    """Analyze root cause of network incidents"""
    try:
        root_cause = await rca_analyzer.analyze(incident_data)
        return {"root_cause": root_cause}
    except Exception as e:
        logger.error(f"Root cause analysis failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/ai/insights")
async def get_ai_insights():
    """Get AI-generated network insights"""
    insights = [
        {
            "id": "insight_1",
            "title": "Network Performance Optimal",
            "description": "All monitored devices showing normal performance patterns",
            "category": "health",
            "type": "health",
            "confidence": 94.7,
            "timestamp": "2 minutes ago"
        },
        {
            "id": "insight_2", 
            "title": "Bandwidth Utilization Trending Up",
            "description": "Core router bandwidth usage increased 15% in last hour",
            "category": "performance",
            "type": "optimization",
            "confidence": 87.3,
            "timestamp": "5 minutes ago"
        }
    ]
    return insights

@app.get("/api/ai/predictions")
async def get_predictions():
    """Get AI predictions"""
    predictions = [
        {
            "id": "pred_1",
            "metric": "Network Throughput",
            "change": 12.5,
            "timeframe": "next 2 hours",
            "accuracy": 89.2,
            "model": "LSTM"
        },
        {
            "id": "pred_2",
            "metric": "CPU Utilization",
            "change": -3.2,
            "timeframe": "next hour",
            "accuracy": 92.1,
            "model": "Random Forest"
        }
    ]
    return predictions

@app.get("/api/ai/recommendations")
async def get_recommendations():
    """Get AI recommendations"""
    recommendations = [
        {
            "id": "rec_1",
            "title": "Optimize BGP Route Selection",
            "description": "Consider adjusting BGP local preference for better load distribution",
            "priority": "medium",
            "savings": "$2,400/month"
        },
        {
            "id": "rec_2",
            "title": "Upgrade Core Switch Memory",
            "description": "Memory utilization approaching 85% threshold on core switch",
            "priority": "high",
            "savings": "Prevent outages"
        }
    ]
    return recommendations

@app.get("/api/ai/anomalies")
async def get_anomalies():
    """Get detected anomalies"""
    anomalies = [
        {
            "id": "anom_1",
            "device": "Core Router 192.168.1.1",
            "metric": "Interface Utilization",
            "deviation": 45.2,
            "severity": "medium",
            "detected_at": "10 minutes ago"
        },
        {
            "id": "anom_2",
            "device": "Access Switch 192.168.1.10", 
            "metric": "Error Rate",
            "deviation": 156.7,
            "severity": "high",
            "detected_at": "2 minutes ago"
        }
    ]
    return anomalies

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8081)
