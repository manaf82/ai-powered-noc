import React, { useState, useEffect } from 'react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar } from 'recharts';
import { 
  Activity, 
  Server, 
  Wifi, 
  AlertTriangle, 
  CheckCircle, 
  Clock,
  TrendingUp,
  TrendingDown,
  Minus
} from 'lucide-react';
import AIInsightsPanel from './AIInsightsPanel';
import NetworkTopology from './NetworkTopology';

const NOCDashboard = () => {
  const [metrics, setMetrics] = useState([]);
  const [devices, setDevices] = useState([]);
  const [alerts, setAlerts] = useState([]);
  const [networkMetrics, setNetworkMetrics] = useState({});
  const [topologyData, setTopologyData] = useState({ nodes: [], links: [] });
  const [activeTab, setActiveTab] = useState('overview');

  useEffect(() => {
    // Fetch initial data
    fetchDashboardData();
    
    // Setup WebSocket connection for real-time updates
    const ws = new WebSocket('ws://localhost:8000/ws/realtime');
    ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      setMetrics(prev => [...prev.slice(-50), data]);
    };
    
    // Cleanup WebSocket on unmount
    return () => ws.close();
  }, []);

  const fetchDashboardData = async () => {
    try {
      const [devicesRes, alertsRes, metricsRes, topologyRes] = await Promise.all([
        fetch('/api/devices'),
        fetch('/api/alerts'),
        fetch('/api/metrics'),
        fetch('/api/topology')
      ]);

      const [devicesData, alertsData, metricsData, topologyDataRes] = await Promise.all([
        devicesRes.json(),
        alertsRes.json(),
        metricsRes.json(),
        topologyRes.json()
      ]);

      setDevices(devicesData.devices || []);
      setAlerts(alertsData.alerts || []);
      setNetworkMetrics(metricsData.metrics || {});
      setTopologyData(topologyDataRes);
    } catch (error) {
      console.error('Error fetching dashboard data:', error);
    }
  };

  const getStatusIcon = (status) => {
    switch (status) {
      case 'up':
      case 'active':
        return <CheckCircle className="h-5 w-5 text-green-500" />;
      case 'down':
        return <AlertTriangle className="h-5 w-5 text-red-500" />;
      case 'degraded':
      case 'warning':
        return <AlertTriangle className="h-5 w-5 text-yellow-500" />;
      default:
        return <Minus className="h-5 w-5 text-gray-500" />;
    }
  };

  const getTrendIcon = (trend) => {
    switch (trend) {
      case 'up':
        return <TrendingUp className="h-4 w-4 text-red-500" />;
      case 'down':
        return <TrendingDown className="h-4 w-4 text-green-500" />;
      default:
        return <Minus className="h-4 w-4 text-gray-500" />;
    }
  };

  const renderOverviewTab = () => (
    <div className="space-y-6">
      {/* Key Metrics Row */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {Object.entries(networkMetrics).map(([key, metric]) => (
          <div key={key} className="metric-card">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-2">
                <Activity className="h-5 w-5 text-noc-blue" />
                <h3 className="text-sm font-medium text-gray-600 capitalize">
                  {key.replace('_', ' ')}
                </h3>
              </div>
              {getTrendIcon(metric.trend)}
            </div>
            <div className="mt-2">
              <div className="text-2xl font-bold text-gray-900">
                {metric.current} {metric.unit}
              </div>
              <p className="text-xs text-gray-500">
                {metric.change > 0 ? '+' : ''}{metric.change}% from last hour
              </p>
            </div>
          </div>
        ))}
      </div>

      {/* Real-time Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="card">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Network Throughput</h3>
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={metrics}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="timestamp" tickFormatter={(time) => new Date(time).toLocaleTimeString()} />
              <YAxis />
              <Tooltip labelFormatter={(time) => new Date(time).toLocaleString()} />
              <Line type="monotone" dataKey="throughput" stroke="#1e40af" strokeWidth={2} />
            </LineChart>
          </ResponsiveContainer>
        </div>

        <div className="card">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Latency & Packet Loss</h3>
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={metrics}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="timestamp" tickFormatter={(time) => new Date(time).toLocaleTimeString()} />
              <YAxis yAxisId="left" />
              <YAxis yAxisId="right" orientation="right" />
              <Tooltip labelFormatter={(time) => new Date(time).toLocaleString()} />
              <Line yAxisId="left" type="monotone" dataKey="latency" stroke="#059669" strokeWidth={2} />
              <Line yAxisId="right" type="monotone" dataKey="packet_loss" stroke="#dc2626" strokeWidth={2} />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Devices and Alerts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="card">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-900">Network Devices</h3>
            <span className="status-indicator status-up">{devices.length} Active</span>
          </div>
          <div className="space-y-3">
            {devices.map(device => (
              <div key={device.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <div className="flex items-center space-x-3">
                  {getStatusIcon(device.status)}
                  <div>
                    <div className="font-medium text-gray-900">{device.name}</div>
                    <div className="text-sm text-gray-500">{device.ip} • {device.location}</div>
                  </div>
                </div>
                <div className="text-right">
                  <div className="text-sm font-medium">CPU: {device.cpu_usage}%</div>
                  <div className="text-sm text-gray-500">RAM: {device.memory_usage}%</div>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-900">Active Alerts</h3>
            <span className="status-indicator status-warning">{alerts.length} Active</span>
          </div>
          <div className="space-y-3">
            {alerts.map(alert => (
              <div key={alert.id} className={`p-3 rounded-lg border-l-4 ${
                alert.severity === 'critical' ? 'border-l-red-500 bg-red-50' :
                alert.severity === 'warning' ? 'border-l-yellow-500 bg-yellow-50' :
                'border-l-blue-500 bg-blue-50'
              }`}>
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <h4 className="font-medium text-gray-900">{alert.title}</h4>
                    <p className="text-sm text-gray-600 mt-1">{alert.description}</p>
                    <div className="flex items-center space-x-2 mt-2">
                      <span className={`status-indicator ${
                        alert.severity === 'critical' ? 'bg-red-100 text-red-800' :
                        alert.severity === 'warning' ? 'bg-yellow-100 text-yellow-800' :
                        'bg-blue-100 text-blue-800'
                      }`}>
                        {alert.severity.toUpperCase()}
                      </span>
                      <span className="text-xs text-gray-500">{alert.timestamp}</span>
                    </div>
                  </div>
                  <AlertTriangle className={`h-5 w-5 ${
                    alert.severity === 'critical' ? 'text-red-500' :
                    alert.severity === 'warning' ? 'text-yellow-500' :
                    'text-blue-500'
                  }`} />
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-4">
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2">
                <Activity className="h-8 w-8 text-noc-blue" />
                <h1 className="text-2xl font-bold text-gray-900">AI-NOC Dashboard</h1>
              </div>
              <div className="flex items-center space-x-2 text-sm text-gray-500">
                <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                <span>Live Monitoring</span>
              </div>
            </div>
            <div className="flex items-center space-x-4">
              <div className="text-sm text-gray-500">
                Last updated: {new Date().toLocaleTimeString()}
              </div>
              <div className="flex items-center space-x-2">
                <CheckCircle className="h-5 w-5 text-green-500" />
                <span className="text-sm font-medium text-green-700">All Systems Operational</span>
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Navigation Tabs */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="border-b border-gray-200">
          <nav className="-mb-px flex space-x-8">
            {[
              { id: 'overview', name: 'Overview', icon: Activity },
              { id: 'topology', name: 'Network Topology', icon: Wifi },
              { id: 'ai-insights', name: 'AI Insights', icon: TrendingUp },
            ].map(tab => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`flex items-center space-x-2 py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === tab.id
                    ? 'border-noc-blue text-noc-blue'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                <tab.icon className="h-5 w-5" />
                <span>{tab.name}</span>
              </button>
            ))}
          </nav>
        </div>
      </div>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {activeTab === 'overview' && renderOverviewTab()}
        {activeTab === 'topology' && <NetworkTopology nodes={topologyData.nodes} links={topologyData.links} />}
        {activeTab === 'ai-insights' && <AIInsightsPanel />}
      </main>
    </div>
  );
};

export default NOCDashboard;