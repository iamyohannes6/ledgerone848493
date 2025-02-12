class PortfolioDataPoint {
  final DateTime timestamp;
  final double value;

  PortfolioDataPoint({
    required this.timestamp,
    required this.value,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.millisecondsSinceEpoch,
    'value': value,
  };

  factory PortfolioDataPoint.fromJson(Map<String, dynamic> json) {
    return PortfolioDataPoint(
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      value: json['value'] as double,
    );
  }
}

class PortfolioHistory {
  final List<PortfolioDataPoint> dataPoints;

  PortfolioHistory({required this.dataPoints});

  Map<String, dynamic> toJson() => {
    'dataPoints': dataPoints.map((point) => point.toJson()).toList(),
  };

  factory PortfolioHistory.fromJson(Map<String, dynamic> json) {
    final List<dynamic> points = json['dataPoints'] as List;
    return PortfolioHistory(
      dataPoints: points.map((point) => PortfolioDataPoint.fromJson(point as Map<String, dynamic>)).toList(),
    );
  }

  // Helper method to get data points for a specific time period
  List<PortfolioDataPoint> getDataForPeriod(String period) {
    final now = DateTime.now();
    final DateTime startDate;

    switch (period) {
      case '1D':
        startDate = now.subtract(const Duration(days: 1));
      case '1W':
        startDate = now.subtract(const Duration(days: 7));
      case '1M':
        startDate = now.subtract(const Duration(days: 30));
      case '1Y':
        startDate = now.subtract(const Duration(days: 365));
      case 'ALL':
        return dataPoints;
      default:
        startDate = now.subtract(const Duration(days: 1));
    }

    return dataPoints
        .where((point) => point.timestamp.isAfter(startDate))
        .toList();
  }
} 