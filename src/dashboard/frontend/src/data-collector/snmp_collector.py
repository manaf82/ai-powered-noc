"""
SNMP Data Collector for network devices
Collects performance metrics from SNMP-enabled devices
"""
import asyncio
from typing import List, Dict, Any
from pysnmp.hlapi.asyncio import *
import logging

logger = logging.getLogger(__name__)

class SNMPCollector:
    def __init__(self):
        self.devices: List[Dict[str, Any]] = []
        self.metrics: Dict[str, Any] = {}
        self.is_running = False
        
    async def initialize(self):
        """Initialize SNMP collector"""
        logger.info("Initializing SNMP Collector")
        # Load device configurations
        self.devices = await self.load_device_config()
        self.is_running = True
        
        # Start collection loop
        asyncio.create_task(self.collection_loop())
    
    async def load_device_config(self) -> List[Dict[str, Any]]:
        """Load device configuration from database"""
        # Sample devices for demonstration
        return [
            {
                "ip": "192.168.1.1",
                "community": "public",
                "device_type": "router",
                "location": "Core Network"
            },
            {
                "ip": "192.168.1.10",
                "community": "public", 
                "device_type": "switch",
                "location": "Access Layer"
            }
        ]
    
    async def collect_metrics(self, device_ip: str, community: str = 'public'):
        """Collect SNMP metrics from a device"""
        metrics = {}
        
        # Define OIDs to collect
        oids = {
            'sysUpTime': '1.3.6.1.2.1.1.3.0',
            'ifInOctets': '1.3.6.1.2.1.2.2.1.10',
            'ifOutOctets': '1.3.6.1.2.1.2.2.1.16',
            'cpuUsage': '1.3.6.1.4.1.9.9.109.1.1.1.1.7.1',
            'memoryUsage': '1.3.6.1.4.1.9.9.221.1.1.1.1.18.1.1'
        }
        
        try:
            for name, oid in oids.items():
                async for errorIndication, errorStatus, errorIndex, varBinds in nextCmd(
                    SnmpEngine(),
                    CommunityData(community),
                    UdpTransportTarget((device_ip, 161)),
                    ContextData(),
                    ObjectType(ObjectIdentity(oid)),
                    lexicographicMode=False
                ):
                    if errorIndication:
                        logger.error(f"SNMP error for {device_ip}: {errorIndication}")
                        break
                    if errorStatus:
                        logger.error(f"SNMP error for {device_ip}: {errorStatus}")
                        break
                    
                    for varBind in varBinds:
                        metrics[name] = int(varBind[1])
                    break
                    
        except Exception as e:
            logger.error(f"Failed to collect SNMP metrics from {device_ip}: {e}")
            
        return metrics
    
    async def collection_loop(self):
        """Main collection loop"""
        while self.is_running:
            try:
                for device in self.devices:
                    metrics = await self.collect_metrics(
                        device['ip'], 
                        device.get('community', 'public')
                    )
                    
                    if metrics:
                        self.metrics[device['ip']] = {
                            'timestamp': asyncio.get_event_loop().time(),
                            'metrics': metrics,
                            'device_info': device
                        }
                        
                        logger.info(f"Collected metrics from {device['ip']}: {len(metrics)} OIDs")
                
                # Wait before next collection cycle
                await asyncio.sleep(30)
                
            except Exception as e:
                logger.error(f"Error in collection loop: {e}")
                await asyncio.sleep(5)
    
    async def cleanup(self):
        """Cleanup resources"""
        self.is_running = False
        logger.info("SNMP Collector stopped")
