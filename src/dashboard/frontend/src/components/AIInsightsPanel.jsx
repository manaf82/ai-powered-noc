// AI-powered insights and recommendations
const AIInsightsPanel = () => {
  const [insights, setInsights] = useState([]);
  
  return (
    <Card>
      <CardHeader>
        <CardTitle>🤖 AI Insights</CardTitle>
      </CardHeader>
      <CardContent>
        {insights.map(insight => (
          <div key={insight.id} className="mb-4 p-3 bg-blue-50 rounded">
            <h4 className="font-semibold">{insight.title}</h4>
            <p className="text-sm text-gray-600">{insight.description}</p>
            <span className="text-xs text-blue-600">Confidence: {insight.confidence}%</span>
          </div>
        ))}
      </CardContent>
    </Card>
  );
};
