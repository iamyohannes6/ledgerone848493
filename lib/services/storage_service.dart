import 'dart:convert';
import 'dart:html' as html;
import '../models/crypto_currency.dart';

class StorageService {
  static const String _cryptoKey = 'crypto_currencies';

  List<CryptoCurrency> getCryptoCurrencies() {
    final String? data = html.window.localStorage[_cryptoKey];
    if (data == null) return _getDefaultCryptoCurrencies();

    List<dynamic> jsonList = json.decode(data);
    return jsonList.map((json) => CryptoCurrency.fromJson(json)).toList();
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
        price: 48000,
        iconColor: 'FFF7931A',
      ),
      CryptoCurrency(
        icon: 'Ξ',
        name: 'Ethereum',
        symbol: 'ETH',
        amount: 0,
        price: 2500,
        iconColor: 'FF627EEA',
      ),
      CryptoCurrency(
        icon: '₮',
        name: 'Tether USD',
        symbol: 'USDT',
        amount: 0,
        price: 1,
        iconColor: 'FF26A17B',
      ),
      CryptoCurrency(
        icon: 'X',
        name: 'XRP',
        symbol: 'XRP',
        amount: 0,
        price: 0.5,
        iconColor: 'FF23292F',
      ),
      CryptoCurrency(
        icon: 'S',
        name: 'Solana',
        symbol: 'SOL',
        amount: 0,
        price: 100,
        iconColor: 'FF00FFA3',
      ),
    ];
  }

  double getTotalBalance() {
    return getCryptoCurrencies()
        .map((currency) => currency.value)
        .fold(0, (prev, curr) => prev + curr);
  }
}
