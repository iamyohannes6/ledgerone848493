import 'dart:convert';
import 'dart:html' as html;
import '../models/crypto_currency.dart';
import '../models/portfolio_history.dart';

class StorageService {
  static const String _cryptoKey = 'crypto_currencies';
  static const String _portfolioHistoryKey = 'portfolio_history';
  List<CryptoCurrency> _currencies = [];
  List<PortfolioDataPoint> _portfolioHistory = [];
  DateTime? _lastDataPointTime;

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
        _portfolioHistory = jsonList
            .map((json) => PortfolioDataPoint.fromJson(json))
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
        if (_portfolioHistory.isNotEmpty) {
          _lastDataPointTime = _portfolioHistory.last.timestamp;
        }
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
    
    // Always add the first point
    if (_portfolioHistory.isEmpty) {
      _portfolioHistory.add(PortfolioDataPoint(timestamp: now, value: value));
      _lastDataPointTime = now;
      _savePortfolioHistory();
      return;
    }
    
    // Check if value has changed significantly (more than 1%)
    final lastValue = _portfolioHistory.last.value;
    final percentChange = ((value - lastValue) / lastValue).abs() * 100;
    
    // Add point if enough time has passed or value changed significantly
    if (_lastDataPointTime == null ||
        now.difference(_lastDataPointTime!).inMinutes >= _getMinimumInterval() ||
        percentChange > 1.0) {
      _portfolioHistory.add(PortfolioDataPoint(timestamp: now, value: value));
      _lastDataPointTime = now;
      
      // Keep only relevant historical data
      _cleanupHistoricalData();
      _savePortfolioHistory();
    }
  }

  int _getMinimumInterval() {
    if (_portfolioHistory.isEmpty) return 1;
    final oldest = _portfolioHistory.first.timestamp;
    final age = DateTime.now().difference(oldest);
    
    if (age.inDays > 365) return 240;    // 4 hours for > 1 year
    if (age.inDays > 30) return 60;      // 1 hour for > 1 month
    if (age.inDays > 7) return 15;       // 15 minutes for > 1 week
    return 5;                            // 5 minutes for <= 1 week
  }

  void _cleanupHistoricalData() {
    final now = DateTime.now();
    
    // Keep more recent points for better graph resolution
    _portfolioHistory.removeWhere((point) {
      final age = now.difference(point.timestamp);
      if (age.inDays > 365) return true;
      if (age.inDays > 30 && age.inMinutes % 240 != 0) return true;   // Keep 4-hour intervals
      if (age.inDays > 7 && age.inMinutes % 60 != 0) return true;     // Keep 1-hour intervals
      if (age.inDays > 1 && age.inMinutes % 15 != 0) return true;     // Keep 15-minute intervals
      return false;
    });

    // Sort the data points by timestamp
    _portfolioHistory.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  List<PortfolioDataPoint> getPortfolioHistory(Duration period) {
    final now = DateTime.now();
    final cutoff = now.subtract(period);
    
    // Get data points for the selected period
    final filteredPoints = _portfolioHistory
        .where((point) => point.timestamp.isAfter(cutoff))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // If no points exist for the period, create points with the current value
    if (filteredPoints.isEmpty) {
      final total = getTotalBalance();
      // Create a series of points leading up to now
      final points = <PortfolioDataPoint>[];
      for (int i = 12; i >= 0; i--) {
        points.add(PortfolioDataPoint(
          timestamp: now.subtract(Duration(
            minutes: (period.inMinutes ~/ 12) * i,
          )),
          value: total,
        ));
      }
      return points;
    }

    return filteredPoints;
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
