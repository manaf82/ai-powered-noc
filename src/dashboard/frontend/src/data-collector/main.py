"""
AI-NOC Data Collector Service
Main entry point for network data collection
"""
import asyncio
import logging
from fastapi import FastAPI
from snmp_collector import SNMPCollector
from netflow_analyzer import NetFlowAnalyzer
from syslog_collector import SyslogCollector

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="AI-NOC Data Collector", version="1.0.0")

# Global collectors
snmp_collector = SNMPCollector()
netflow_analyzer = NetFlowAnalyzer()
syslog_collector = SyslogCollector()

@app.on_startup
async def startup_event():
    """Initialize collectors on startup"""
    logger.info("Starting AI-NOC Data Collector Service")
    await snmp_collector.initialize()
    await netflow_analyzer.start()
    await syslog_collector.start()

@app.on_shutdown
async def shutdown_event():
    """Cleanup on shutdown"""
    logger.info("Shutting down AI-NOC Data Collector Service")
    await snmp_collector.cleanup()
    await netflow_analyzer.stop()
    await syslog_collector.stop()

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "data-collector",
        "collectors": {
            "snmp": snmp_collector.is_running,
            "netflow": netflow_analyzer.is_running,
            "syslog": syslog_collector.is_running
        }
    }

@app.get("/metrics")
async def get_metrics():
    """Get collector metrics"""
    return {
        "snmp_devices": len(snmp_collector.devices),
        "netflow_flows": netflow_analyzer.flow_count,
        "syslog_messages": syslog_collector.message_count
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
