class CryptoCurrency {
  final String name;
  final String symbol;
  final double amount;
  final double value;
  final String iconColor;
  final String icon;
  final String logoUrl;
  final double percentChange24h;
  final bool isEnabled;

  CryptoCurrency({
    required this.name,
    required this.symbol,
    this.amount = 0,
    this.value = 0,
    required this.iconColor,
    required this.icon,
    required this.logoUrl,
    this.percentChange24h = 0.0,
    this.isEnabled = true,
  });

  CryptoCurrency copyWith({
    String? name,
    String? symbol,
    double? amount,
    double? value,
    String? iconColor,
    String? icon,
    String? logoUrl,
    double? percentChange24h,
    bool? isEnabled,
  }) {
    return CryptoCurrency(
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      amount: amount ?? this.amount,
      value: value ?? this.value,
      iconColor: iconColor ?? this.iconColor,
      icon: icon ?? this.icon,
      logoUrl: logoUrl ?? this.logoUrl,
      percentChange24h: percentChange24h ?? this.percentChange24h,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'symbol': symbol,
        'amount': amount,
        'value': value,
        'iconColor': iconColor,
        'icon': icon,
        'logoUrl': logoUrl,
        'percentChange24h': percentChange24h,
        'isEnabled': isEnabled,
      };

  factory CryptoCurrency.fromJson(Map<String, dynamic> json) => CryptoCurrency(
        name: json['name'] as String,
        symbol: json['symbol'] as String,
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        value: (json['value'] as num?)?.toDouble() ?? 0,
        iconColor: json['iconColor'] as String,
        icon: json['icon'] as String,
        logoUrl: json['logoUrl'] as String,
        percentChange24h: (json['percentChange24h'] as num?)?.toDouble() ?? 0,
        isEnabled: json['isEnabled'] as bool? ?? true,
      );
}
