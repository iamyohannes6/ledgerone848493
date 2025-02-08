import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/crypto_currency.dart';

class WalletService {
  static const String _cryptoKey = 'crypto_currencies';
  final SharedPreferences _prefs;

  WalletService(this._prefs);

  List<CryptoCurrency> getCryptoCurrencies() {
    final String? data = _prefs.getString(_cryptoKey);
    if (data == null) return _getDefaultCryptoCurrencies();

    List<dynamic> jsonList = json.decode(data);
    return jsonList.map((json) => CryptoCurrency.fromJson(json)).toList();
  }

  Future<void> saveCryptoCurrencies(List<CryptoCurrency> currencies) async {
    final String data = json.encode(
      currencies.map((currency) => currency.toJson()).toList(),
    );
    await _prefs.setString(_cryptoKey, data);
  }

  Future<void> updateCryptoCurrency(CryptoCurrency currency) async {
    final currencies = getCryptoCurrencies();
    final index = currencies.indexWhere((c) => c.symbol == currency.symbol);
    if (index != -1) {
      currencies[index] = currency;
      await saveCryptoCurrencies(currencies);
    }
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
