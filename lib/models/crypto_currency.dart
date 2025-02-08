class CryptoCurrency {
  String icon;
  String name;
  String symbol;
  double amount;
  double price;
  String iconColor;

  CryptoCurrency({
    required this.icon,
    required this.name,
    required this.symbol,
    required this.amount,
    required this.price,
    required this.iconColor,
  });

  double get value => amount * price;

  Map<String, dynamic> toJson() => {
        'icon': icon,
        'name': name,
        'symbol': symbol,
        'amount': amount,
        'price': price,
        'iconColor': iconColor,
      };

  factory CryptoCurrency.fromJson(Map<String, dynamic> json) => CryptoCurrency(
        icon: json['icon'] as String,
        name: json['name'] as String,
        symbol: json['symbol'] as String,
        amount: (json['amount'] as num).toDouble(),
        price: (json['price'] as num).toDouble(),
        iconColor: json['iconColor'] as String,
      );
}
