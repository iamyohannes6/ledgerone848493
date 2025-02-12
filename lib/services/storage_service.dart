import 'dart:convert';
import 'dart:html' as html;
import '../models/crypto_currency.dart';
import '../models/portfolio_history.dart';

class StorageService {
  static const String _cryptoKey = 'crypto_currencies';
  static const String _portfolioHistoryKey = 'portfolio_history';
  List<CryptoCurrency> _currencies = [];
  List<PortfolioDataPoint> _portfolioHistory = [];

  StorageService() {
    _loadFromStorage();
    _loadPortfolioHistory();
  }

  void _loadFromStorage() {
    final storedData = html.window.localStorage[_cryptoKey];
    if (storedData != null) {
      try {
        final List<dynamic> jsonList = json.decode(storedData);
        _currencies = jsonList.map((json) => CryptoCurrency.fromJson(json)).toList();
      } catch (e) {
        print('Error loading from storage: $e');
        _initializeDefaultCurrencies();
      }
    } else {
      _initializeDefaultCurrencies();
    }
  }

  void _loadPortfolioHistory() {
    final storedData = html.window.localStorage[_portfolioHistoryKey];
    if (storedData != null) {
      try {
        final List<dynamic> jsonList = json.decode(storedData);
        _portfolioHistory = jsonList.map((json) => PortfolioDataPoint.fromJson(json)).toList();
      } catch (e) {
        print('Error loading portfolio history: $e');
        _portfolioHistory = [];
      }
    }
  }

  void _initializeDefaultCurrencies() {
    _currencies = [
      CryptoCurrency(
        icon: '₿',
        name: 'Bitcoin',
        symbol: 'BTC',
        amount: 0,
        value: 0,
        iconColor: 'F7931A',
        logoUrl: 'https://cryptologos.cc/logos/bitcoin-btc-logo.png',
      ),
      CryptoCurrency(
        icon: 'Ξ',
        name: 'Ethereum',
        symbol: 'ETH',
        amount: 0,
        value: 0,
        iconColor: '627EEA',
        logoUrl: 'https://cryptologos.cc/logos/ethereum-eth-logo.png',
      ),
      CryptoCurrency(
        icon: '₮',
        name: 'Tether',
        symbol: 'USDT',
        amount: 0,
        value: 0,
        iconColor: '26A17B',
        logoUrl: 'https://cryptologos.cc/logos/tether-usdt-logo.png',
      ),
      CryptoCurrency(
        icon: '✕',
        name: 'Ripple',
        symbol: 'XRP',
        amount: 0,
        value: 0,
        iconColor: '23292F',
        logoUrl: 'https://cryptologos.cc/logos/xrp-xrp-logo.png',
      ),
      CryptoCurrency(
        icon: '◎',
        name: 'Solana',
        symbol: 'SOL',
        amount: 0,
        value: 0,
        iconColor: '00FFA3',
        logoUrl: 'https://cryptologos.cc/logos/solana-sol-logo.png',
      ),
    ];
    _saveToStorage();
  }

  void _saveToStorage() {
    final jsonList = _currencies.map((currency) => currency.toJson()).toList();
    html.window.localStorage[_cryptoKey] = json.encode(jsonList);
  }

  void addPortfolioDataPoint(double value) {
    final now = DateTime.now();
    
    // Don't add duplicate points within the same minute
    if (_portfolioHistory.isNotEmpty) {
      final lastPoint = _portfolioHistory.last;
      if (now.difference(lastPoint.timestamp).inMinutes == 0 && 
          (lastPoint.value - value).abs() < 0.01) {
        return;
      }
    }
    
    _portfolioHistory.add(PortfolioDataPoint(timestamp: now, value: value));
    
    // Keep only last 5 years of data for 'ALL' view
    final fiveYearsAgo = now.subtract(const Duration(days: 365 * 5));
    _portfolioHistory.removeWhere((point) => point.timestamp.isBefore(fiveYearsAgo));
    
    // Reduce data points density for older periods
    _optimizeDataPoints();
    
    _savePortfolioHistory();
  }

  void _optimizeDataPoints() {
    final now = DateTime.now();
    final points = List<PortfolioDataPoint>.from(_portfolioHistory);
    points.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    // Keep all points from last 24 hours
    final oneDayAgo = now.subtract(const Duration(days: 1));
    final recentPoints = points.where((p) => p.timestamp.isAfter(oneDayAgo)).toList();
    
    // For older points, reduce density based on age
    final olderPoints = points.where((p) => !p.timestamp.isAfter(oneDayAgo)).toList();
    if (olderPoints.isNotEmpty) {
      final oneWeekAgo = now.subtract(const Duration(days: 7));
      final oneMonthAgo = now.subtract(const Duration(days: 30));
      final oneYearAgo = now.subtract(const Duration(days: 365));
      
      // Keep hourly points for last week
      final weekPoints = _reducePoints(
        olderPoints.where((p) => p.timestamp.isAfter(oneWeekAgo)).toList(),
        const Duration(hours: 1)
      );
      
      // Keep daily points for last month
      final monthPoints = _reducePoints(
        olderPoints.where((p) => 
          p.timestamp.isAfter(oneMonthAgo) && 
          !p.timestamp.isAfter(oneWeekAgo)
        ).toList(),
        const Duration(days: 1)
      );
      
      // Keep weekly points for last year
      final yearPoints = _reducePoints(
        olderPoints.where((p) => 
          p.timestamp.isAfter(oneYearAgo) && 
          !p.timestamp.isAfter(oneMonthAgo)
        ).toList(),
        const Duration(days: 7)
      );
      
      // Keep monthly points for older data
      final oldestPoints = _reducePoints(
        olderPoints.where((p) => !p.timestamp.isAfter(oneYearAgo)).toList(),
        const Duration(days: 30)
      );
      
      _portfolioHistory = [
        ...oldestPoints,
        ...yearPoints,
        ...monthPoints,
        ...weekPoints,
        ...recentPoints,
      ];
    } else {
      _portfolioHistory = recentPoints;
    }
  }

  List<PortfolioDataPoint> _reducePoints(List<PortfolioDataPoint> points, Duration interval) {
    if (points.isEmpty) return [];
    
    final result = <PortfolioDataPoint>[];
    var currentInterval = points.first.timestamp;
    var currentPoints = <PortfolioDataPoint>[];
    
    for (final point in points) {
      if (point.timestamp.isBefore(currentInterval.add(interval))) {
        currentPoints.add(point);
      } else {
        if (currentPoints.isNotEmpty) {
          // Add average point for the interval
          final avgValue = currentPoints.map((p) => p.value).reduce((a, b) => a + b) / currentPoints.length;
          result.add(PortfolioDataPoint(
            timestamp: currentInterval,
            value: avgValue,
          ));
        }
        currentInterval = point.timestamp;
        currentPoints = [point];
      }
    }
    
    // Add the last interval
    if (currentPoints.isNotEmpty) {
      final avgValue = currentPoints.map((p) => p.value).reduce((a, b) => a + b) / currentPoints.length;
      result.add(PortfolioDataPoint(
        timestamp: currentInterval,
        value: avgValue,
      ));
    }
    
    return result;
  }

  List<PortfolioDataPoint> getPortfolioHistory(Duration period) {
    final now = DateTime.now();
    final cutoff = now.subtract(period);
    
    // Ensure we have at least one data point
    if (_portfolioHistory.isEmpty) {
      final total = _calculateTotalBalance();
      addPortfolioDataPoint(total);
    }
    
    return _portfolioHistory
      .where((point) => point.timestamp.isAfter(cutoff))
      .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  double _calculateTotalBalance() {
    return _currencies.fold(0.0, (sum, currency) => sum + (currency.amount * currency.value));
  }

  void _savePortfolioHistory() {
    final jsonList = _portfolioHistory.map((point) => point.toJson()).toList();
    html.window.localStorage[_portfolioHistoryKey] = json.encode(jsonList);
  }

  List<CryptoCurrency> getCryptoCurrencies() {
    return List.from(_currencies);
  }

  void addCurrency(CryptoCurrency currency) {
    _currencies.add(currency);
    _saveToStorage();
  }

  void updateCurrency(int index, CryptoCurrency currency) {
    if (index >= 0 && index < _currencies.length) {
      _currencies[index] = currency;
      _saveToStorage();
    }
  }

  void updateCurrencies(List<CryptoCurrency> currencies) {
    _currencies = currencies;
    _saveToStorage();
  }

  void deleteCurrency(int index) {
    if (index >= 0 && index < _currencies.length) {
      _currencies.removeAt(index);
      _saveToStorage();
    }
  }

  double getTotalBalance() {
    final total = _currencies.fold(0.0, (sum, currency) => sum + (currency.amount * currency.value));
    // Add data point to history when getting total balance
    addPortfolioDataPoint(total);
    return total;
  }

  Future<void> saveCryptoCurrencies(List<CryptoCurrency> currencies) async {
    final String data = json.encode(
      currencies.map((currency) => currency.toJson()).toList(),
    );
    html.window.localStorage[_cryptoKey] = data;
  }

  Future<void> updateCryptoCurrency(CryptoCurrency currency) async {
    final currencies = getCryptoCurrencies();
    final index = currencies.indexWhere((c) => c.symbol == currency.symbol);
    if (index != -1) {
      currencies[index] = currency;
      await saveCryptoCurrencies(currencies);
    }
  }

  Future<void> addCryptoCurrency(CryptoCurrency currency) async {
    final currencies = getCryptoCurrencies();
    if (currencies.any((c) => c.symbol == currency.symbol)) {
      throw Exception('Currency with symbol ${currency.symbol} already exists');
    }
    currencies.add(currency);
    await saveCryptoCurrencies(currencies);
  }

  List<CryptoCurrency> _getDefaultCryptoCurrencies() {
    return [
      CryptoCurrency(
        icon: '₿',
        name: 'Bitcoin',
        symbol: 'BTC',
        amount: 0,
        value: 48000,
        iconColor: 'F7931A',
        logoUrl: 'https://cryptologos.cc/logos/bitcoin-btc-logo.png',
      ),
      CryptoCurrency(
        icon: 'Ξ',
        name: 'Ethereum',
        symbol: 'ETH',
        amount: 0,
        value: 2500,
        iconColor: '627EEA',
        logoUrl: 'https://cryptologos.cc/logos/ethereum-eth-logo.png',
      ),
      CryptoCurrency(
        icon: '₮',
        name: 'Tether USD',
        symbol: 'USDT',
        amount: 0,
        value: 1,
        iconColor: '26A17B',
        logoUrl: 'https://cryptologos.cc/logos/tether-usdt-logo.png',
      ),
      CryptoCurrency(
        icon: 'X',
        name: 'XRP',
        symbol: 'XRP',
        amount: 0,
        value: 0.5,
        iconColor: '23292F',
        logoUrl: 'https://cryptologos.cc/logos/xrp-xrp-logo.png',
      ),
      CryptoCurrency(
        icon: 'S',
        name: 'Solana',
        symbol: 'SOL',
        amount: 0,
        value: 100,
        iconColor: '00FFA3',
        logoUrl: 'https://cryptologos.cc/logos/solana-sol-logo.png',
      ),
    ];
  }
}
