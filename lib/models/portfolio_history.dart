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