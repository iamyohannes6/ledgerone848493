import 'dart:convert';
import 'dart:html' as html;
import '../models/crypto_currency.dart';

class StorageService {
  static const String _cryptoKey = 'crypto_currencies';
  List<CryptoCurrency> _currencies = [];

  StorageService() {
    _loadFromStorage();
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

  void _initializeDefaultCurrencies() {
    _currencies = [
      CryptoCurrency(
        icon: '₿',
        name: 'Bitcoin',
        symbol: 'BTC',
        amount: 2.5,
        value: 48000,
        iconColor: 'F7931A',
        logoUrl: 'https://cryptologos.cc/logos/bitcoin-btc-logo.png',
      ),
      CryptoCurrency(
        icon: 'Ξ',
        name: 'Ethereum',
        symbol: 'ETH',
        amount: 10.2,
        value: 2500,
        iconColor: '627EEA',
        logoUrl: 'https://cryptologos.cc/logos/ethereum-eth-logo.png',
      ),
      CryptoCurrency(
        icon: '₮',
        name: 'Tether',
        symbol: 'USDT',
        amount: 5000,
        value: 1,
        iconColor: '26A17B',
        logoUrl: 'https://cryptologos.cc/logos/tether-usdt-logo.png',
      ),
      CryptoCurrency(
        icon: '✕',
        name: 'Ripple',
        symbol: 'XRP',
        amount: 15000,
        value: 0.5,
        iconColor: '23292F',
        logoUrl: 'https://cryptologos.cc/logos/xrp-xrp-logo.png',
      ),
      CryptoCurrency(
        icon: '◎',
        name: 'Solana',
        symbol: 'SOL',
        amount: 150,
        value: 100,
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
    return _currencies.fold(0.0, (sum, currency) => sum + (currency.amount * currency.value));
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
